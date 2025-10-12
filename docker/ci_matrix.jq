# Save a reference to top object.
. as $o |
# Build a mapping of images being built.
[ .[] | { key: (.image), value: true } ] | from_entries as $images |
# And produce an updated version of the top object input with
# each `.base` member stripped when not one of the built images.
# NOTE: we also convert an image base name to its build ID.
[ $o | .[] | . as $i |
  # When publishing, the base image will be available from the registry.
  .base |= (
    select(if $publish == "" then $images | has($i | .base) else false end) |
    ltrimstr($registry + "/" + $namespace + "/") | gsub("[/:]"; " ")
  )
]
