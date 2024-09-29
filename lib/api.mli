(** Api includes functions that map to the Spotify Web REST API.
    See {{:https://developer.spotify.com/documentation/web-api}here} for an up
    to date reference.

    All functions will also automatically refresh the {!Client.User} object and return
    an updated one alongside the normal API response.*)

type image = { url : string; height : int option; width : int option }
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
  (*available_markets : string list;*)
  external_urls : externalUrl;
  href : string;
  id : string;
  images : image list;
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
  images : image list option;
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
  (*available_markets : string list;*)
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

type user = {
  external_urls : externalUrl;
  followers : followers;
  href : string;
  id : string;
  type_ : string;
  uri : string;
  display_name : string option;
}

type playlist = {
  collaborative : bool;
  description : string;
  external_urls : externalUrl;
  href : string;
  id : string;
  images : image list;
  name : string;
  owner : user;
  public : bool;
  snapshot_id : string;
  tracks : track list;
  type_ : string;
  uri : string;
}

type copyright = { text : string; type_ : string }

type show = {
  (*available_markets : string list;*)
  copyrights : copyright list;
  description : string;
  html_description : string;
  explicit : bool;
  external_urls : externalUrl;
  href : string;
  id : string;
  images : image;
  is_externally_hosted : bool;
  languages : string list;
  media_type : string;
  name : string;
  publisher : string;
  type_ : string;
  uri : string;
  total_episodes : int;
}

type resume_point = { fully_played : bool; resume_position_ms : int }

type episode = {
  audio_preview_url : string option;
  description : string;
  html_description : string;
  duration_ms : int;
  explicit : bool;
  external_urls : externalUrl;
  href : string;
  id : string;
  images : image;
  is_externally_hosted : bool;
  is_playable : bool;
  languages : string list;
  name : string;
  release_date_precision : string;
  resume_point : resume_point;
  type_ : string;
  uri : string;
  restrictions : restrictions;
}

type author = { name : string }
type narrator = { name : string }

type audiobook = {
  authors : author;
  (*available_markets : string list;*)
  copyrights : copyright;
  description : string;
  html_description : string;
  edition : string;
  explicit : bool;
  external_urls : externalUrl;
  href : string;
  id : string;
  images : image;
  languages : string list;
  media_type : string;
  name : string;
  narrators : narrator;
  publisher : string;
  type_ : string;
  uri : string;
  total_chapters : int;
}

type query_item_type =
  | Album
  | Artist
  | Playlist
  | Track
  | Show
  | Episode
  | Audiobook

type album_response = {
  href : string;
  limit : int;
  next : string option;
  offset : int;
  previous : string option;
  total : int;
  items : album list;
}

type artist_response = {
  href : string;
  limit : int;
  next : string option;
  offset : int;
  previous : string option;
  total : int;
  items : artist list;
}

type playlist_response = {
  href : string;
  limit : int;
  next : string option;
  offset : int;
  previous : string option;
  total : int;
  items : playlist list;
}

type track_response = {
  href : string;
  limit : int;
  next : string option;
  offset : int;
  previous : string option;
  total : int;
  items : track list;
}

type show_response = {
  href : string;
  limit : int;
  next : string option;
  offset : int;
  previous : string option;
  total : int;
  items : show list;
}

type episode_response = {
  href : string;
  limit : int;
  next : string option;
  offset : int;
  previous : string option;
  total : int;
  items : episode list;
}

type audiobook_response = {
  href : string;
  limit : int;
  next : string option;
  offset : int;
  previous : string option;
  total : int;
  items : audiobook list;
}

type query_response = {
  albums : album_response;
  artists : artist_response;
  playlists : playlist_response;
  tracks : track_response;
  shows : show_response;
  episodes : episode_response;
  audiobooks : audiobook_response;
}

val user_top_tracks :
  user:Client.User.t -> (track_response, Client.apiError) Result.t Lwt.t
(** Returns the users' top tracks.*)

val string_of_query_item_type : query_item_type -> string

val search :
  item_types:query_item_type list ->
  client:Client.t ->
  ?market:string ->
  ?limit:string ->
  ?offset:string ->
  ?include_external:string ->
  string ->
  (query_response, Client.apiError) Result.t Lwt.t
(** https://developer.spotify.com/documentation/web-api/reference/search *)
