module User : sig
  type t

  val to_string : user:t -> (string, Serde.error) result
  val of_string : user:string -> (t, Serde.error) result

  val of_auth_response :
    access_token:string ->
    refresh_token:string ->
    expires_in:int ->
    scope:string ->
    t

  val access_token : user:t -> string
  val refresh_token : user:t -> string
  val is_valid : user:t -> bool
end

module Client : sig
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
end

module Api : sig
  type imageObject = { url : string; height : int option; width : int option }
  type externalUrl = { spotify : string }
  type followers = { href : string option; total : int }
  type restrictions = { reason : string }

  type simplifiedArtist = {
    external_urls : externalUrl;
    href : string;
    id : string;
    name : string;
    item_type : string;
    uri : string;
  }

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
    item_type : string;
    uri : string;
    artists : simplifiedArtist list;
  }

  type artist = {
    external_urls : externalUrl;
    followers : followers option;
    genres : string list option;
    href : string;
    id : string;
    images : imageObject list option;
    name : string;
    popularity : int option;
    item_type : string;
    uri : string;
  }

  type external_ids = {
    isrc : string;
    ean : string option;
    upc : string option;
  }

  type linked_from = { anything : string option }

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
    track_type : string;
    uri : string;
    is_local : bool;
  }

  type userTopTracksResponse = {
    href : string;
    limit : int;
    next : string option;
    offset : int;
    previous : string option;
    total : int;
    items : track list;
  }

  type userTopArtistsResponse = {
    href : string;
    limit : int;
    next : string option;
    offset : int;
    previous : string option;
    total : int;
    items : artist list;
  }

  val user_top_tracks :
    client:Client.t ->
    user:User.t ->
    (userTopTracksResponse * User.t, Serde.error) result Lwt.t
  (** Returns the users' top tracks and also an updated User object. *)
end
