/-  *metadata-store
/+  *metadata-json
|_  upd=metadata-update
++  grad  %noun
++  grow
  |%
  ++  noun  upd
  ++  resource
    ?>  ?=(?(%add %remove %initial-group %updated-metadata) -.upd)
    group.upd
  ++  json  (update-to-json upd)
  --
::
++  grab
  |%
  ++  noun  metadata-update
  ++  json  json-to-action
  --
::
--
