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
      expires_at = expires_in + int_of_float (Unix.time ());
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
      Format.eprintf "trying to ge a user \n";
      Serde_json.of_string deserialize_t user
    in
    Format.eprintf "we got a user.. maybe?\n";
    user

  let access_token ~user = user.access_token
  let refresh_token ~user = user.refresh_token

  let is_valid ~user =
    let is_valid = user.expires_at >= int_of_float (Unix.time ()) + 3000 in
    Format.eprintf "is valid? %b\n" is_valid;
    is_valid
end

module Client = struct
  module Config : sig
    type t

    val client_id : config:t -> string
    val make : client_id:string -> client_secret:string -> t
    val make_empty : t

    val request_token : config:t -> string
    (** Returns client_id:client_secret base64 encoded. *)
  end = struct
    type t = { client_id : string; client_secret : string }

    let make ~client_id ~client_secret = { client_id; client_secret }
    let make_empty = { client_id = ""; client_secret = "" }
    let client_id ~config = config.client_id

    let request_token ~config =
      Base64.encode_exn (config.client_id ^ ":" ^ config.client_secret)
  end

  type t = { config : Config.t }

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
  [@@deriving serialize, deserialize]

  type auth_response =
    | User of user_auth_response
    | Server of server_auth_response
  [@@deriving serialize, deserialize]

  let auth_url = Uri.of_string "https://accounts.spotify.com/authorize"
  let token_url = Uri.of_string "https://accounts.spotify.com/api/token"

  let make ~client_id ~client_secret =
    { config = Config.make ~client_id ~client_secret }

  let make_empty = { config = Config.make_empty }

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

  let print_response print (resp, body) =
    let open Cohttp in
    let open Lwt in
    if print then (
      let code = resp |> Response.status |> Code.code_of_status in
      Printf.printf "Response code: %d\n" code;
      Printf.printf "Headers: %s\n"
        (resp |> Response.headers |> Header.to_string);
      body |> Cohttp_lwt.Body.to_string >|= fun body ->
      Printf.printf "Body: %s\n" body;
      body)
    else body |> Cohttp_lwt.Body.to_string >|= fun body -> body

  let user_of_userAuthResponse ~resp =
    Format.eprintf "making user of: %s\n" resp;
    Serde_json.of_string deserialize_user_auth_response resp
    |> Result.map (fun user ->
           User.of_auth_response ~access_token:user.access_token
             ~refresh_token:user.refresh_token ~scope:user.scope
             ~expires_in:user.expires_in)
    |> Lwt.return

  let login_as_user ~client ~auth_code ~uri =
    Format.eprintf "logging in as user...\n";
    let request_token = Config.request_token ~config:client.config in
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
    user_of_userAuthResponse ~resp

  let get ~user ~url =
    let open Lwt in
    let headers =
      Cohttp.Header.init ()
      |> ph "Authorization" ("Bearer " ^ User.access_token ~user)
    in
    let req =
      Cohttp_lwt_unix.Client.get ~headers (Uri.of_string url)
      >>= print_response false
    in
    req

  let refresh_user ~client ~user : (User.t, Serde.error) result Lwt.t =
    Printf.eprintf "user no longer valid. Refreshing token.\n";
    let request_token = Config.request_token ~config:client.config in
    let headers =
      Cohttp.Header.init () |> ph "Authorization" ("Basic " ^ request_token)
    in
    let params =
      [
        ("grant_type", [ "refresh_token" ]);
        ("refresh_token", [ User.refresh_token ~user ]);
      ]
    in
    let open Lwt in
    let%lwt resp =
      Cohttp_lwt_unix.Client.post_form ~headers ~params token_url
      >>= print_response true
    in
    user_of_userAuthResponse ~resp
end

module Api = struct
  type imageObject = { url : string; height : int option; width : int option }
  [@@deriving deserialize]

  type externalUrl = { spotify : string } [@@deriving deserialize]

  type followers = { href : string option; total : int }
  [@@deriving deserialize]

  type restrictions = { reason : string } [@@deriving deserialize]

  type simplifiedArtist = {
    external_urls : externalUrl;
    href : string;
    id : string;
    name : string;
    item_type : string; [@serde { rename = "type" }]
    uri : string;
  }
  [@@deriving deserialize]

  type album = {
    album_type : string;
    total_tracks : int;
    available_markets : string list;
    external_urls : externalUrl;
    href : string;
    id : string;
    images : imageObject list;
    name : string;
    release_date : string;
    release_date_precision : string;
    restrictions : restrictions option;
    item_type : string; [@serde { rename = "type" }]
    uri : string;
    artists : simplifiedArtist list;
  }
  [@@deriving deserialize]

  type artist = {
    external_urls : externalUrl;
    followers : followers option;
    genres : string list option;
    href : string;
    id : string;
    images : imageObject list option;
    name : string;
    popularity : int option;
    item_type : string; [@serde { rename = "type" }]
    uri : string;
  }
  [@@deriving deserialize]

  type external_ids = {
    isrc : string;
    ean : string option;
    upc : string option;
  }
  [@@deriving deserialize]

  (* We don't know what this looks like *)
  type linked_from = { anything : string option } [@@deriving deserialize]

  type track = {
    album : album;
    artists : artist list;
    available_markets : string list;
    disc_number : int;
    duration_ms : int;
    explicit : bool;
    external_ids : external_ids;
    external_urls : externalUrl;
    href : string;
    id : string;
    is_playable : bool option;
    linked_from : linked_from option;
    restrictions : restrictions option;
    name : string;
    popularity : int;
    preview_url : string option;
    track_number : int;
    track_type : string; [@serde { rename = "type" }]
    uri : string;
    is_local : bool;
  }
  [@@deriving deserialize]

  type userTopTracksResponse = {
    href : string;
    limit : int;
    next : string option;
    offset : int;
    previous : string option;
    total : int;
    items : track list;
  }
  [@@deriving deserialize]

  type userTopArtistsResponse = {
    href : string;
    limit : int;
    next : string option;
    offset : int;
    previous : string option;
    total : int;
    items : artist list;
  }
  [@@deriving deserialize]

  let base_url = "https://api.spotify.com/v1"

  let get_tracks ~user ~url :
      (userTopTracksResponse * User.t, Serde.error) result Lwt.t =
    Format.eprintf "getting tracks for user: \n";
    let%lwt resp = Client.get ~user ~url in
    let maybe_tracks =
      Serde_json.of_string deserialize_userTopTracksResponse resp
    in
    Lwt.return
      (match maybe_tracks with
      | Ok tracks -> Ok (tracks, user)
      | Error e ->
          Format.eprintf "can't get user top tracks response: %s\n" resp;
          Serde.pp_err Format.err_formatter e;
          Error e)

  let user_top_tracks ~client ~user =
    Format.eprintf "getting user's top tracks...\n";
    let%lwt user =
      if User.is_valid ~user then Lwt.return (Ok user)
      else Client.refresh_user ~client ~user
    in
    match user with
    | Error e ->
        Format.eprintf "Can't get user: n";
        Serde.pp_err Format.err_formatter e;
        Lwt.return (Error e)
    | Ok user ->
        let url = base_url ^ "/me/top/tracks" in
        let tracks = get_tracks ~url ~user in
        tracks
end
