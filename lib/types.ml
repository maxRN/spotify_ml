type image = { url : string; height : int option; width : int option }
[@@deriving deserialize]

type externalUrl = { spotify : string } [@@deriving deserialize]
type followers = { href : string option; total : int } [@@deriving deserialize]
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
  images : image list;
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
  images : image list option;
  name : string;
  popularity : int option;
  item_type : string; [@serde { rename = "type" }]
  uri : string;
}
[@@deriving deserialize]

type external_ids = { isrc : string; ean : string option; upc : string option }
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

type user = {
  external_urls : externalUrl;
  followers : followers;
  href : string;
  id : string;
  type_ : string;
  uri : string;
  display_name : string option;
}
[@@deriving deserialize]

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
[@@deriving deserialize]

type copyright = { text : string; type_ : string } [@@deriving deserialize]

type show = {
  available_markets : string list;
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
[@@deriving deserialize]

type resume_point = { fully_played : bool; resume_position_ms : int }
[@@deriving deserialize]

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
[@@deriving deserialize]

type author = { name : string } [@@deriving deserialize]
type narrator = { name : string } [@@deriving deserialize]

type audiobook = {
  authors : author;
  available_markets : string list;
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
[@@deriving deserialize]

type album_response = {
  href : string;
  limit : int;
  next : string option;
  offset : int;
  previous : string option;
  total : int;
  items : album list;
}
[@@deriving deserialize]

type artist_response = {
  href : string;
  limit : int;
  next : string option;
  offset : int;
  previous : string option;
  total : int;
  items : artist list;
}
[@@deriving deserialize]

type playlist_response = {
  href : string;
  limit : int;
  next : string option;
  offset : int;
  previous : string option;
  total : int;
  items : playlist list;
}
[@@deriving deserialize]

type track_response = {
  href : string;
  limit : int;
  next : string option;
  offset : int;
  previous : string option;
  total : int;
  items : track list;
}
[@@deriving deserialize]

type show_response = {
  href : string;
  limit : int;
  next : string option;
  offset : int;
  previous : string option;
  total : int;
  items : show list;
}
[@@deriving deserialize]

type episode_response = {
  href : string;
  limit : int;
  next : string option;
  offset : int;
  previous : string option;
  total : int;
  items : episode list;
}
[@@deriving deserialize]

type audiobook_response = {
  href : string;
  limit : int;
  next : string option;
  offset : int;
  previous : string option;
  total : int;
  items : audiobook list;
}
[@@deriving deserialize]

type query_response = {
  albums : album_response;
  artists : artist_response;
  playlists : playlist_response;
  tracks : track_response;
  shows : show_response;
  episodes : episode_response;
  audiobooks : audiobook_response;
}
[@@deriving deserialize]

type query_item_type =
  | Album
  | Artist
  | Playlist
  | Track
  | Show
  | Episode
  | Audiobook

let string_of_query_item_type = function
  | Album -> "album"
  | Artist -> "artist"
  | Playlist -> "playlist"
  | Track -> "track"
  | Show -> "show"
  | Episode -> "episode"
  | Audiobook -> "audiobook"
