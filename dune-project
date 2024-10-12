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
  serde
  serde_derive
  serde_json
  (lwt_ppx
   (= 2.1.0))
  (cohttp-lwt-unix
   (= 5.3.0)))
 (tags (spotify)))

(pin (package (name serde_json)) (url "git+https://github.com/maxrn/serde"))
(pin (package (name serde)) (url "git+https://github.com/maxrn/serde"))
(pin (package (name serde_derive)) (url "git+https://github.com/maxrn/serde"))
