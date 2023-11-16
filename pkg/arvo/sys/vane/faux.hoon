::  %faux
!:
!?  164
::
=,  faux
|=  our=ship
=>  |%
    +$  move  [p=duct q=(wite note gift)]
    +$  note  ~
    +$  sign  ~
    +$  faux-state
      $:  %0
          ~
      ==
    --
::
=|  faux-state
=*  state  -
|=  [now=@da eny=@uvJ rof=roof]
=*  faux-gate  .
^?
|%
::  +call: handle a +task request
::
++  call
  |=  $:  hen=duct
          dud=(unit goof)
          wrapped-task=(hobo task)
      ==
  ^-  [(list move) _faux-gate]
  ~&  "%faux: call with task {<wrapped-task>}"
  `faux-gate
::  +load: migrate an old state to a new vane version
::
++  load
  |=  old=faux-state
  ^+  faux-gate
  faux-gate(state old)
::  +scry: view vane state at a particular /path
::
++  scry
  ^-  roon
  |=  [lyc=gang pov=path car=term bem=beam]
  ^-  (unit (unit cage))
  ~&  "%faux: scry at path {<pov>}"
  ``noun+!>(~)
::  +stay: extract state before reload
::
++  stay
  state
::  +take: handle $response sign
::
++  take
  |=  [tea=wire hen=duct dud=(unit goof) hin=sign]
  ^-  [(list move) _faux-gate]
  ~&  "%faux: take at wire {<tea>}"
  `faux-gate
--
