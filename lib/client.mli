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

val make : client_id:string -> client_secret:string -> t
val make_empty : t

val redirect_uri :
  client:t -> scope:string -> redirect_uri:string -> state:string -> Uri.t

val login_as_user :
  client:t ->
  auth_code:string ->
  uri:string ->
  (User.t, Serde.error) result Lwt.t

val refresh_user :
  client:t -> old_user:User.t -> (User.t, Serde.error) result Lwt.t

val get : user:User.t -> url:string -> string Lwt.t
