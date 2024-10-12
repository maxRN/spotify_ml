(** OCaml bindings for the {{:https://developer.spotify.com/documentation/web-api}Spotify Web API} *)

(** An authenticated user that can be used to access user specific information. *)
module User : sig
  type t

  val to_string : user:t -> (string, Serde.error) result
  val of_string : user:string -> (t, Serde.error) result

  val is_valid : user:t -> bool
  (** A user token is usually only valid for 1h. You can use this function to
        check if the user token is expired.*)
end

type t
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
  | ErrorSerialization of (string * Serde.error)
      (** This happens when the response returned by Spotify doesn't match the declared types.*)

val make : client_id:string -> client_secret:string -> t

val redirect_uri :
  client:t -> scope:string -> redirect_uri:string -> state:string -> Uri.t

val login_as_user :
  client:t ->
  auth_code:string ->
  uri:string ->
  (User.t, Serde.error) result Lwt.t

val refresh_user :
  client:t -> old_user:User.t -> (User.t, Serde.error) result Lwt.t

val get : user:User.t -> url:string -> (string, requestError) Result.t Lwt.t

val get_no_user : client:t -> url:string -> (string, apiError) Result.t Lwt.t
(** This is used for endpoints that don't require a user. *)
