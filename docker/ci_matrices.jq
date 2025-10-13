def build(built):
  . as $jobs |
  # What can we build? (no base or base is already built)
  [$jobs[] | select(.base == null or (.base | in(built)))] as $nodeps |
  # Create updated `built` mapping.
  (built + ([ $nodeps[] | { key: .id, value: true } ] | from_entries)) as $built |
  # What's left to build?
  [$jobs[] | select(.id | in($built) | not)] as $left |
  # Output build matrices.
  [{ matrix: $nodeps }] + if $left | length == 0 then [] else $left | build($built) end
;

# Save a reference to top object.
. as $o |
# Build a mapping of images being built.
[ $o[] | { key: (.image), value: true } ] | from_entries as $images |
# Produce an updated version of the top object input with each
# `.base` member stripped when not one of the images being built.
# NOTE: we also convert an image base name to its build ID.
[ $o[] | . as $i | .base |= (
 select(.|in($images)) |
 ltrimstr($registry + "/" + $namespace + "/") |
 gsub("[/:]"; " ")
) ] |
# Generate build matrices.
build({})

# vim sw: 2
