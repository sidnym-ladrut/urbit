/+  *test, pp=pprint, ep=eprint
|%
++  test-trivial
  ~&  >  "trivial"
  %-  expect-eq-type-vase-pprints
  :~  !>(*@)                                                           ::  atom
      !>([*@ *@])                                                      ::  cell
      !>(%$)                                                           ::  term
      !>(/)                                                            ::  path
      !>(*?(%a %b))                                                    ::  fork
  ==
::
::  ++  test-simple
::    ~&  >  "simple"
::    %-  expect-eq-type-vase-pprints
::    :~  !>(/a/b/c)                                                       ::  path
::        !>(*bean)                                                        ::  fork
::        !>(`(list @)`~[0 1 2])                                           ::  list
::        !>(`(tree @)`[1 [0 ~ ~] [2 ~ ~]])                                ::  tree
::        !>(*peer-state:ames)                                             ::  hint
::        !>(=>(~ |=(a=@ +(a))))                                           ::  core
::    ==
::  ::
::  ++  test-complex
::    ~&  >  "complex"
::    %-  expect-eq-type-vase-pprints
::    :~  !>(/(scot %p *@p)/pprint/(scot %da *@da))                        ::  path
::    ==
::
++  expect-eq-type-vase-pprints
  |=  vaz=(list vase)
  ^-  tang
  ;:  weld
      ~&  >>  "types"
      (expect-eq-pprints vaz oprint-type pprint-type)
      ~&  >>  "vases"
      (expect-eq-pprints vaz oprint-vase pprint-vase)
  ==
::
++  expect-eq-pprints
  |=  [vaz=(list vase) ref=$-(vase tape) tes=$-(vase tape)]
  %+  roll  vaz
  |=  [vas=vase acc=tang]
  ~&  >>>  (ref vas)
  ~&  >>>  (tes vas)
  %+  weld  acc
  (expect-eq !>((ref vas)) !>((tes vas)))
::
++  pprint-type  |=(v=vase `tape`~(ram re ~(duck ur:pp (doxx:ur:pp p.v))))
++  pprint-vase  |=(v=vase `tape`~(ram re (~(deal ur:pp (doxx:ur:pp p.v)) q.v)))
++  eprint-type  |=(v=vase `tape`~(ram re ~(duck ep p.v)))
++  eprint-vase  |=(v=vase `tape`~(ram re (~(deal ep p.v) q.v)))
++  oprint-type  |=(v=vase `tape`~(ram re ~(duck us p.v)))
++  oprint-vase  |=(v=vase `tape`~(ram re (~(deal us p.v) q.v)))
--
