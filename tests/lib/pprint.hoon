/+  *test, pp=pprint
|%
++  test-placeholder
  ~&  (type2tape:pp -:!>(/hello/world))
  ~&  (vase2tape:pp !>(/hello/world))
  %+  expect-eq
    !>  %.y
    !>  %.y
::
--
