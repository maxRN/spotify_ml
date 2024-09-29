open Base
include Types

let base_url = "https://api.spotify.com/v1"

let deserialize x =
  Serde_json.of_string deserialize_track_response x
  |> Result.map_error ~f:(fun e -> Client.ErrorSerialization e)

let user_top_tracks ~user =
  let url = base_url ^ "/me/top/tracks" in
  let%lwt resp = Client.get ~user ~url in
  let resp = resp |> Result.map_error ~f:(fun e -> Client.ErrorClient e) in
  Result.bind resp ~f:deserialize |> Lwt.return

let search ~item_types ~client ?market ?limit ?offset ?include_external query =
  let uri = Uri.of_string @@ base_url ^ "/search" in

  let uri =
    match market with
    | Some m -> Uri.add_query_param' uri ("market", m)
    | None -> uri
  in
  let uri =
    match limit with
    | Some l -> Uri.add_query_param' uri ("limit", l)
    | None -> uri
  in
  let uri =
    match offset with
    | Some o -> Uri.add_query_param' uri ("offset", o)
    | None -> uri
  in
  let uri =
    match include_external with
    | Some e -> Uri.add_query_param' uri ("include_external", e)
    | None -> uri
  in

  let uri = Uri.add_query_param' uri ("q", query) in

  let item_types = List.map ~f:string_of_query_item_type item_types in
  let item_types = String.concat ~sep:"," item_types in
  let uri = Uri.add_query_param' uri ("type", item_types) in

  let%lwt resp = Client.get_no_user ~client ~url:(Uri.to_string uri) in
  Lwt.return
  @@ Result.bind
       ~f:(fun e ->
         let oc = Out_channel.open_text "logs.txt" in
         Stdlib.Printf.fprintf oc "got response body: %s\n%!" e;
         Out_channel.close oc;
         Serde_json.of_string deserialize_query_response e
         |> Result.map_error ~f:(fun e -> Client.ErrorSerialization e))
       resp
