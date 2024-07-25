(lang dune 3.16)

(name spotify_ml)

(generate_opam_files true)

(source
 (github maxrn/spotify_ml))

(authors "maxrn")

(maintainers "maxrn")

(license MIT)

(package
 (name spotify_ml)
 (synopsis "Spotify API bindings")
 (description "Interact with the Spotify Web API via OCaml.")
 (depends
  ocaml
  dune
  (ocamlformat (and :dev (= 0.26.2) ))
  (serde (= 0.0.2))
  (serde_derive (= 0.0.2))
  (serde_json (= 0.0.2))
  (lwt_ppx (= 2.1.0))
  (cohttp-lwt-unix (= 5.3.0))
  )
 (tags (spotify)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
