(lang dune 3.16)

(name spotify_ml)

(generate_opam_files true)

(source
 (github maxrn/spotify_ml))

(authors "maxrn")

(maintainers "maxrn")

(license MIT)

(documentation https://url/to/documentation)

(package
 (name spotify_ml)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
  ocaml
  dune
  (ocamlformat :dev)
  serde
  serde_derive
  lwt_ppx
  serde_json
  cohttp-lwt-unix)
 (tags (spotify)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
