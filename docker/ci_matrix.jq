# Save a reference to top object.
. as $o |
# Build a mapping of images being built.
[ .[] | { key: (.image), value: true } ] | from_entries as $images |
# And produce an updated version of the top object input with
# each `.base` member stripped when not one of the built images.
# NOTE: we also convert an image base name to its build ID.
[ $o | .[] | . as $i |
  .base |= (
    select($images | has($i | .base)) |
    ltrimstr($registry + "/" + $namespace + "/") | gsub("[/:]"; " ")
  )
]
