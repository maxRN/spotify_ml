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
  (*available_markets : string list;*)
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

(*"album" : {*)
(*  "album_type" : "single",*)
(*  "artists" : [ {*)
(*    "external_urls" : {*)
(*      "spotify" : "https://open.spotify.com/artist/7u2xfrEmdl48CV6A2iADUZ"*)
(*    },*)
(*    "href" : "https://api.spotify.com/v1/artists/7u2xfrEmdl48CV6A2iADUZ",*)
(*    "id" : "7u2xfrEmdl48CV6A2iADUZ",*)
(*    "name" : "The Troys",*)
(*    "type" : "artist",*)
(*    "uri" : "spotify:artist:7u2xfrEmdl48CV6A2iADUZ"*)
(*  } ],*)
(*  "available_markets" : [ "AR", "AU", "AT", "BE", "BO", "BR", "BG", "CA", "CL", "CO", "CR", "CY", "CZ", "DK", "DO", "DE", "EC", "EE", "SV", "FI", "FR", "GR", "GT", "HN", "HK", "HU", "IS", "IE", "IT", "LV", "LT", "LU", "MY", "MT", "MX", "NL", "NZ", "NI", "NO", "PA", "PY", "PE", "PH", "PL", "PT", "SG", "SK", "ES", "SE", "CH", "TW", "TR", "UY", "US", "GB", "AD", "LI", "MC", "ID", "JP", "TH", "VN", "RO", "IL", "ZA", "SA", "AE", "BH", "QA", "OM", "KW", "EG", "MA", "DZ", "TN", "LB", "JO", "PS", "IN", "BY", "KZ", "MD", "UA", "AL", "BA", "HR", "ME", "MK", "RS", "SI", "KR", "BD", "PK", "LK", "GH", "KE", "NG", "TZ", "UG", "AG", "AM", "BS", "BB", "BZ", "BT", "BW", "BF", "CV", "CW", "DM", "FJ", "GM", "GE", "GD", "GW", "GY", "HT", "JM", "KI", "LS", "LR", "MW", "MV", "ML", "MH", "FM", "NA", "NR", "NE", "PW", "PG", "WS", "SM", "ST", "SN", "SC", "SL", "SB", "KN", "LC", "VC", "SR", "TL", "TO", "TT", "TV", "VU", "AZ", "BN", "BI", "KH", "CM", "TD", "KM", "GQ", "SZ", "GA", "GN", "KG", "LA", "MO", "MR", "MN", "NP", "RW", "TG", "UZ", "ZW", "BJ", "MG", "MU", "MZ", "AO", "CI", "DJ", "ZM", "CD", "CG", "IQ", "LY", "TJ", "VE", "ET", "XK" ],*)
(*  "external_urls" : {*)
(*    "spotify" : "https://open.spotify.com/album/5vCdgjadRxvDLviclUG0Az"*)
(*  },*)
(*  "href" : "https://api.spotify.com/v1/albums/5vCdgjadRxvDLviclUG0Az",*)
(*  "id" : "5vCdgjadRxvDLviclUG0Az",*)
(*  "images" : [ {*)
(*    "height" : 640,*)
(*    "url" : "https://i.scdn.co/image/ab67616d0000b273bb5f7afa79a33e710fcdd188",*)
(*    "width" : 640*)
(*  }, {*)
(*    "height" : 300,*)
(*    "url" : "https://i.scdn.co/image/ab67616d00001e02bb5f7afa79a33e710fcdd188",*)
(*    "width" : 300*)
(*  }, {*)
(*    "height" : 64,*)
(*    "url" : "https://i.scdn.co/image/ab67616d00004851bb5f7afa79a33e710fcdd188",*)
(*    "width" : 64*)
(*  } ],*)
(*  "name" : "What Do You Do",*)
(*  "release_date" : "2003-03-04",*)
(*  "release_date_precision" : "day",*)
(*  "total_tracks" : 1,*)
(*  "type" : "album",*)
(*  "uri" : "spotify:album:5vCdgjadRxvDLviclUG0Az"*)
(*},*)

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
  albums : album_response option;
  artists : artist_response option;
  playlists : playlist_response option;
  tracks : track_response option;
  shows : show_response option;
  episodes : episode_response option;
  audiobooks : audiobook_response option;
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
[@@deriving deserialize]

let string_of_query_item_type = function
  | Album -> "album"
  | Artist -> "artist"
  | Playlist -> "playlist"
  | Track -> "track"
  | Show -> "show"
  | Episode -> "episode"
  | Audiobook -> "audiobook"
