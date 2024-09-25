(lang dune 3.16)

(name spotify_ml)

(generate_opam_files true)

(source
 (github maxrn/spotify_ml))

(authors "Max Große <max12.gro@gmail.com>")

(maintainers "Max Große <max12.gro@gmail.com>")

(license MIT)

(package
 (name spotify_ml)
 (synopsis "Spotify API bindings")
 (description "Interact with the Spotify Web API via OCaml.")
 (depends
  (serde
   (= 0.0.2))
  (serde_derive
   (= 0.0.2))
  (serde_json
   (= 0.0.2))
  (lwt_ppx
   (= 2.1.0))
  (cohttp-lwt-unix
   (= 5.3.0)))
 (tags (spotify)))
