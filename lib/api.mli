(** Api bindings *)

(** Api includes functions that map to the Spotify Web REST API.
    See {{:https://developer.spotify.com/documentation/web-api}here} for an up
    to date reference.

    All functions will also automatically refresh the {!Client.User} object and return
    an updated one alongside the normal API response.*)

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

type external_ids = { isrc : string; ean : string option; upc : string option }
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

type httpError = { code : int; message : string }

type requestError =
  | Token of httpError
      (** Bad or expired token. This can happen if the user revoked a token or
          the access token has expired. You should re-authenticate the user. *)
  | OAuth of httpError
      (** Bad OAuth request (wrong consumer key, bad nonce, expired timestamp...).
        Unfortunately, re-authenticating the user won't help here. *)
  | RateLimit of httpError  (** The app has exceeded its rate limits.*)

val user_top_tracks :
  client:Client.t ->
  user:Client.User.t ->
  (userTopTracksResponse * Client.User.t, Serde.error) result Lwt.t
(** Returns the users' top tracks.*)
