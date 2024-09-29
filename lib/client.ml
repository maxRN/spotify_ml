module User = struct
  type t = {
    access_token : string;
    scope : string;
    expires_at : int; (* Unix timestamp *)
    refresh_token : string;
  }
  [@@deriving serialize, deserialize]

  let of_auth_response ~access_token ~refresh_token ~expires_in ~scope =
    {
      access_token;
      refresh_token;
      expires_at = expires_in + Int.of_float (Unix.time ());
      scope;
    }

  let to_string ~user =
    let user =
      {
        access_token = user.access_token;
        scope = user.scope;
        expires_at = user.expires_at;
        refresh_token = user.refresh_token;
      }
    in
    Serde_json.to_string serialize_t user

  let of_string ~user =
    let user =
      Stdlib.Format.eprintf "trying to ge a user \n";
      Serde_json.of_string deserialize_t user
    in
    Stdlib.Format.eprintf "we got a user.. maybe?\n";
    user

  let access_token ~user = user.access_token
  let refresh_token ~user = user.refresh_token

  let is_valid ~user =
    let is_valid = user.expires_at >= Int.of_float (Unix.time ()) + 3000 in
    Stdlib.Format.eprintf "is valid? %b\n" is_valid;
    is_valid
end

module Config : sig
  type t

  val client_id : config:t -> string
  val make : client_id:string -> client_secret:string -> t

  val request_token : t -> string
  (** Returns client_id:client_secret base64 encoded. *)
end = struct
  type t = { client_id : string; client_secret : string }

  let make ~client_id ~client_secret = { client_id; client_secret }
  let client_id ~config = config.client_id

  let request_token config =
    Base64.encode_exn (config.client_id ^ ":" ^ config.client_secret)
end

type token = { access_token : string; expires_at : int }

let make_empty_token = { access_token = ""; expires_at = 0 }

type t = { config : Config.t; mutable token : token }
type httpError = { code : int; message : string }

type requestError =
  | ErrorToken of httpError
      (** Bad or expired token. This can happen if the user revoked a token or
          the access token has expired. You should re-authenticate the user. *)
  | ErrorOAuth of httpError
      (** Bad OAuth request (wrong consumer key, bad nonce, expired timestamp...).
        Unfortunately, re-authenticating the user won't help here. *)
  | ErrorRateLimit of httpError  (** The app has exceeded its rate limits.*)
  | ErrorUnknown of httpError  (** Unexpected error happened.*)

type apiError =
  | ErrorClient of requestError
  | ErrorSerialization of Serde.error
      (** This happens when the response returned by Spotify doesn't match the declared types.*)

type server_auth_response = {
  access_token : string;
  token_type : string;
  expires_in : int;
}
[@@deriving serialize, deserialize]

type user_auth_response = {
  access_token : string;
  token_type : string;
  scope : string;
  expires_in : int;
  refresh_token : string;
  error : string option;
  error_description : string option;
}
[@@deriving deserialize]

type user_refresh_response = {
  access_token : string;
  scope : string;
  expires_in : int;
  error : string option;
  error_description : string option;
}
[@@deriving deserialize]

type auth_response =
  | User of user_auth_response
  | Server of server_auth_response
[@@deriving deserialize]

let auth_url = Uri.of_string "https://accounts.spotify.com/authorize"
let token_url = Uri.of_string "https://accounts.spotify.com/api/token"

let make ~client_id ~client_secret =
  { config = Config.make ~client_id ~client_secret; token = make_empty_token }

let redirect_uri ~client ~scope ~redirect_uri ~state =
  Uri.add_query_params auth_url
    [
      ("response_type", [ "code" ]);
      ("client_id", [ Config.client_id ~config:client.config ]);
      ("scope", [ scope ]);
      ("redirect_uri", [ redirect_uri ]);
      ("state", [ state ]);
    ]

let ph name value header = Cohttp.Header.add header name value
let body_of_string body = body |> Cohttp_lwt.Body.to_string

let error_from_response (resp, body) : (string, requestError) Result.t Lwt.t =
  let open Cohttp in
  let code = resp |> Response.status |> Code.code_of_status in
  let%lwt body = body_of_string body in
  (match code with
  | 200 -> Ok body
  | 401 -> Error (ErrorToken { code; message = body })
  | 403 -> Error (ErrorOAuth { code; message = body })
  | 429 -> Error (ErrorRateLimit { code; message = body })
  | _ -> Error (ErrorUnknown { code; message = body }))
  |> Lwt.return

let print_response print (resp, body) =
  let open Cohttp in
  let open Lwt in
  if print then (
    let code = resp |> Response.status |> Code.code_of_status in
    Stdlib.Printf.printf "Response code: %d\n" code;
    Stdlib.Printf.printf "Headers: %s\n"
      (resp |> Response.headers |> Header.to_string);
    body |> Cohttp_lwt.Body.to_string >|= fun body ->
    Stdlib.Printf.printf "Body: %s\n" body;
    body)
  else body |> Cohttp_lwt.Body.to_string >|= fun body -> body

let login_as_user ~client ~auth_code ~uri =
  let open Base in
  Stdlib.Format.eprintf "logging in as user...\n";
  let request_token = Config.request_token client.config in
  let headers =
    Cohttp.Header.init () |> ph "Authorization" ("Basic " ^ request_token)
  in
  let params =
    [
      ("grant_type", [ "authorization_code" ]);
      ("code", [ auth_code ]);
      ("redirect_uri", [ uri ]);
    ]
  in
  let open Lwt in
  let%lwt resp =
    Cohttp_lwt_unix.Client.post_form ~headers ~params token_url
    >>= print_response false
  in
  Serde_json.of_string deserialize_user_auth_response resp
  |> Result.map ~f:(fun user ->
         Stdlib.Printf.eprintf
           "user auth response: token type: %s error: %s error_description: %s\n"
           user.token_type
           (Option.value ~default:"no error" user.error)
           (Option.value ~default:"no error" user.error_description);
         user)
  |> Result.map ~f:(fun (user : user_auth_response) ->
         User.of_auth_response ~access_token:user.access_token
           ~refresh_token:user.refresh_token ~scope:user.scope
           ~expires_in:user.expires_in)
  |> Lwt.return

let get ~user ~url =
  let headers =
    Cohttp.Header.init ()
    |> ph "Authorization" ("Bearer " ^ User.access_token ~user)
  in
  let%lwt req = Cohttp_lwt_unix.Client.get ~headers (Uri.of_string url) in
  error_from_response req

let refresh_user ~client ~old_user =
  let open Base in
  let request_token = Config.request_token client.config in
  let headers =
    Cohttp.Header.init () |> ph "Authorization" ("Basic " ^ request_token)
  in
  let params =
    [
      ("grant_type", [ "refresh_token" ]);
      ("refresh_token", [ User.refresh_token ~user:old_user ]);
    ]
  in
  let open Lwt in
  let%lwt resp =
    Cohttp_lwt_unix.Client.post_form ~headers ~params token_url
    >>= print_response true
  in
  Serde_json.of_string deserialize_user_refresh_response resp
  |> Result.map ~f:(fun (user : user_refresh_response) ->
         Stdlib.Printf.eprintf
           "user_refresh_response: error: %s error_description: %s\n"
           (Option.value ~default:"no error" user.error)
           (Option.value ~default:"no error" user.error_description);
         user)
  |> Result.map ~f:(fun user ->
         User.of_auth_response ~access_token:user.access_token
           ~refresh_token:old_user.refresh_token ~scope:user.scope
           ~expires_in:user.expires_in)
  |> Lwt.return

let login_client client : (server_auth_response, Serde.error) Result.t Lwt.t =
  let auth_token = Config.request_token client.config in
  let headers =
    Cohttp.Header.init () |> ph "Authorization" ("Basic " ^ auth_token)
  in
  let params = [ ("grant_type", [ "client_credentials" ]) ] in
  let open Lwt in
  let%lwt resp =
    Cohttp_lwt_unix.Client.post_form ~headers ~params token_url
    >>= print_response false
  in
  let maybe_server_auth =
    Serde_json.of_string deserialize_server_auth_response resp
  in
  maybe_server_auth |> Lwt.return

let get_no_user_valid ~token ~url : (string, apiError) Result.t Lwt.t =
  let open Base in
  let headers =
    Cohttp.Header.init () |> ph "Authorization" @@ "Bearer " ^ token
  in
  let%lwt req = Cohttp_lwt_unix.Client.get ~headers (Uri.of_string url) in
  let%lwt maybe_client = error_from_response req in
  Result.map_error ~f:(fun e -> ErrorClient e) maybe_client |> Lwt.return

let get_no_user ~client ~url : (string, apiError) Result.t Lwt.t =
  let open Base in
  if client.token.expires_at < Int.of_float (Unix.time ()) then
    let%lwt login_resp = login_client client in
    let login_resp =
      Result.map_error ~f:(fun e -> ErrorSerialization e) login_resp
    in
    match login_resp with
    | Ok auth_response ->
        let new_token =
          {
            access_token = auth_response.access_token;
            expires_at =
              (Int.of_float @@ Unix.time ()) + auth_response.expires_in;
          }
        in
        client.token <- new_token;
        get_no_user_valid ~token:client.token.access_token ~url
    | Error e -> Lwt.return @@ Error e
  else get_no_user_valid ~token:client.token.access_token ~url
