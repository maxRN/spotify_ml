type imageObject = { url : string; height : int option; width : int option }
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

type httpError = { code : int; message : string }

type requestError =
  | Token of httpError
  | OAuth of httpError
  | RateLimit of httpError

let base_url = "https://api.spotify.com/v1"

let get_tracks ~user ~url :
    (userTopTracksResponse * Client.User.t, Serde.error) result Lwt.t =
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
    if Client.User.is_valid ~user then Lwt.return (Ok user)
    else Client.refresh_user ~client ~old_user:user
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
