|%
++  ur
  =>  |%
      +$  tase  (each type vase)                        ::  type/vase
      +$  seen  [p=(set tase) q=(map type @)]           ::  track holds
      +$  base  $-([tase seen] (unit [seen tank]))      ::  base printer
      +$  ppin  $-([tase seen base] (unit [seen tank])) ::  custom printer
      --
  ::
  |_  $:  veb=?(%base %most %lest)                      ::  default verbosity
          pin=(map term ppin)                           ::  print overrides
      ==
  ::
  ++  draw  |=(inp=tase +:(need (disc inp [~ ~])))      ::  print type/vase
  ::
  ++  disc                                              ::  base printer
    |=  [inp=tase sen=seen]
    ^-  (unit [seen tank])
    =+  typ=?-(-.inp %& p.inp, %| p.p.inp)
    |^  ?:  (~(meet ut typ) -:!>(*type))
          (dial %typo)            ::  #t, #t/XX
        (dial ?@(typ typ -.typ))  ::  %atom/%cell/%face/etc.
    ::
    ++  dial                                            ::  call printer
      |=  mar=term
      ?~  custom=(~(get by pin) mar)
        (defs mar)  ::  TODO: maybe get rid of +defs and do it here
      (u.custom inp sen disc)
    ::
    ++  defs                                            ::  default printers
      |=  mar=term
      :: ~&  mar
      ^-  (unit [seen tank])
      |^  ?+  mar  ~
            %typo  typo
            %noun  noun
            %void  void
            %atom  atom
            %cell  cell
            %core  core
            %face  face
            %fork  fork
            %hint  hint
            %hold  hold
            %unit  unit
            %list  list
            %tape  tape
            %path  path
            %wall  wall
            %wain  wain
            %tree  tree
            %map   map
            %set   set
            %qeu   qeu
          ==
      ::
      ++  typo
        ?-    -.inp
          %&  `[sen [%leaf "#t"]]
          %|  =+  tyr=|.((disc inp sen))
              =+  vol=tyr(inp [%& q.p.inp])
              =+  cis=;;(tank +>:.*(vol [%9 2 %0 1]))  ::  TODO: we can cast the tank but not the seen
              `[sen [%palm [~ ~ ~ ~] [[%leaf "#t/"] cis ~]]]
        ==
      ::
      ++  noun
        ?-   -.inp
          %&  `[sen [%leaf "*"]]
          %|  =-  (disc inp(p.p -) sen)
              ?@  q.p.inp  [%atom %$ ~]
              [%cell %noun %noun]  ::  !>(*)  causes PP to loop forever here
        ==
      ::
      ++  void  ?:(-.inp ~ `[sen [%leaf "#!"]])
      ::
      ++  atom
        ?>  ?=([%atom *] typ)
        ?-  -.inp
          %&  ?~  q.typ  
                `[sen [%leaf '@' (trip p.typ)]]
              `[sen [%leaf '%' ~(rend co [%$ p.typ u.q.typ])]]
          %|  ?~  q.typ
                ?.  ?=(@ q.p.inp)  ~
                :-  ~
                :-  sen
                :-  %leaf
                ?+    (rash p.typ ;~(sfix (cook crip (star low)) (star hig)))
                    ~(rend co [%$ p.typ q.p.inp])
                  %$    ~(rend co [%$ %ud q.p.inp])
                  %t    (dash (rip 3 q.p.inp) '\'' ~)
                  %tas  ['%' ?.(=(0 q.p.inp) (rip 3 q.p.inp) ['$' ~])]
                ==
              ?.  =(q.p.inp u.q.typ)  ~ 
              =.  p.typ  (rash p.typ ;~(sfix (cook crip (star low)) (star hig)))
              =+  fox=(disc inp(p.p [%atom p.typ ~]) sen)
              ?~  fox  ~
              ?>  ?=([%leaf ^] +.u.fox)
              ?:  ?=(?(%n %tas) p.typ)  fox
              `[sen [%leaf '%' p.+.u.fox]]
        ==
      ::
      ++  cell
        ?>  ?=([%cell *] typ)
        =-  ?~  -  ~
            `[->- [%rose [[' ' ~] ['[' ~] [']' ~]] ->+]]
        =-  ?.  ?=([^ ^] -)  ~
            ?.  ?&  ?=([%cell *] q.typ)
                    ?=([%rose *] +.u.tal)
                ==
              `[-.u.tal [+.u.hed +.u.tal ~]]
            `[-.u.tal (weld [+.u.hed ~] q.+.u.tal)]
        ?-  -.inp
          %&  =+  hed=(disc inp(p p.typ) sen)
              ?~  hed  [hed=~ tal=~]
              =+  tal=(disc inp(p q.typ) sen(q ->.u.hed))
              [hed=hed tal=tal]
          %|  ?.  ?=(^ q.p.inp)  ~
              =+  hed=(disc inp(p.p p.typ, q.p -:q.p.inp) sen)
              ?~  hed  [hed=~ tal=~]
              =+  tal=(disc inp(p.p q.typ, q.p +:q.p.inp) sen(q ->.u.hed))
              [hed=hed tal=tal]
        ==
      ::
      ++  core  
        ?>  ?=([%core *] typ)
        =+  res=(disc [%& p.typ] sen)
        ?~  res  ~
        :-  ~
        :-  -.u.res
        :+  %rose  [[' ' ~] ['<' ~] ['>' ~]]
        :_  ?:  ?&  ?=([%rose *] +.u.res)
                    =([[' ' ~] ['<' ~] ['>' ~]] p.+.u.res) 
                ==
              q.+.u.res 
            [+.u.res ~]
        :-  %leaf
        %+  rip  3
        %^  cat  3
            %~  rent  co
            :+  %$  %ud
            %-  ~(rep by (~(run by q.r.q.typ) |=(tome ~(wyt by q.+<))))
            |=([[@ a=@u] b=@u] (add a b))
        %^  cat  3
            ?-(r.p.q.typ %gold '.', %iron '|', %lead '?', %zinc '&')
        =+  gum=(mug q.r.q.typ)
        %+  can  3
        :~  [1 (add 'a' (mod gum 26))]
            [1 (add 'a' (mod (div gum 26) 26))]
            [1 (add 'a' (mod (div gum 676) 26))]
        ==
      ::
      ++  hint
        ?>  ?=([%hint *] typ)
        =+  hin=?-(-.inp %& inp(p q.typ), %| inp(p.p q.typ))
        ::
        :: ~&  ['hint' q.p.typ]
        ?.  ?=([%know *] q.p.typ)  (disc hin sen)
        ::
        ?:  ?&(?=(%lest veb) -.inp)
          ?@  tud=p.q.p.typ  `[sen (cat 3 '#' mark.tud)]
          `[sen (rap 3 '#' auth.tud '+' (spat type.tud) ~)]
        ::
        ?^  p.q.p.typ  (disc hin sen)
        ::
        ?^  custom=(~(get by pin) p.q.p.typ)
          (u.custom hin sen disc)
        ::
        ?^  def=(defs(typ q.typ) p.q.p.typ)  def
        ::
        ?.  -.inp  (disc hin sen)
        `[sen (cat 3 '#' p.q.p.typ)]
      ::
      ++  face
        ?>  ?=([%face *] typ)
        ?-  -.inp
          %&  =+  (disc inp(p q.typ) sen)
              ?~  -  ~
              ?^  p.typ   -
              `[-.u.- [%palm [['=' ~] ~ ~ ~] [%leaf (trip p.typ)] +.u.- ~]]
          %|  (disc inp(p.p q.typ) sen)
        ==
      ::
      ++  fork
        ?>  ?=([%fork *] typ)
        =+  yed=(sort ~(tap in p.typ) aor)
        ?-  -.inp
          %&  =-  `[-< [%rose [[' ' ~] ['?' '(' ~] [')' ~]] ->]]
              |-  ^-  [seen (^list tank)]
              ?~  yed  [sen ~]
              =+  mor=$(yed t.yed)
              =+  dis=(disc inp(p i.yed) sen(q ->:mor))
              ?~   dis  [sen ~]
              [-:u.dis +:u.dis +:mor]
          %|  |-  ^-  (^unit [seen tank])
              ?~  yed  ~
              =+  (disc inp(p.p i.yed) sen)
              ?^(- - $(yed t.yed))
        ==
      ::
      ++  hold
      ?>  ?=([%hold *] typ)
      ?-  -.inp
        %&  =+  lef=|=(num=@ud ['#' ~(rend co [%$ %ud num])])
            ?^  hey=(~(get by q.sen) typ)
              `[sen [%leaf (lef u.hey)]]
            ?:  (~(has in p.sen) inp)
              =+  dyr=+(~(wyt by q.sen))
              `[sen(q (~(put by q.sen) typ dyr)) [%leaf (lef dyr)]]
            =+  rom=(disc inp(p ~(repo ut typ)) sen(p (~(put in p.sen) inp)))
            ?~  rom  ~
            :-  ~
            :-  sen(q ->.u.rom)
            ?~  rey=(~(get by q.-.u.rom) typ)  +.u.rom
            [%palm [['.' ~] ~ ~ ~] [%leaf '^' (lef u.rey)] +.u.rom ~]
        %|  ?:  (~(has in p.sen) inp)  ~
            (disc inp(p.p ~(repo ut typ)) sen(p (~(put in p.sen) inp)))
      ==
      :: 
      ++  unit
        ?>  ?=([%fork *] typ)
        =+  yed=(sort ~(tap in p.typ) aor)
        ?>  ?=([* [[%cell * [%face *]] ~]] yed)
        ?-    -.inp
          %&  =+  (disc [%& +<+>+>.yed] sen)
              ?~  -  ~
              `[->- [%rose [" " "u(" ")"] ->+ ~]]
          %|  ?:  =(q.p.inp ~)  `[sen [%leaf "~"]]
              =+  (disc [%| +<+>.yed +:q.p.inp] sen)
              ?~  -  ~
              `[->- [%rose [" " "[" "]"] [[%leaf "~"] ->+ ~]]]
        ==
      ::
      ++  list
        ?>  ?=([%fork *] typ)
        =+  yed=(sort ~(tap in p.typ) aor)
        ?>  ?=([* [[%cell [%face *] [%face *]] ~]] yed)
        =+  =+  yod=+<+<+>.yed
            |-  ^-  term
            ?:  =(-:!>(*^tape) yod)             %wall
            ?:  ?=([%atom %'tD' ~] yod)         %tape
            ?:  ?=([%atom %t ~] yod)            %wain  ::  all (list @t) are wain?
            ?:  ?=([%atom %ta ~] yod)           %path
            ?.  ?=(?([%hint *] [%hold *]) yod)  %list
            $(yod ~(repo ut yod))
        ?.  ?=(%list -)  (defs -)
        ?-  -.inp
          %&  =+  (disc inp(p +<+<+>.yed) sen)
              ?~  -  ~
              `[->- [%rose [" " "(list " ")"] [->+ ~]]]
          %|  =+  (deck ;;((^list *) q.p.inp) +<+<+>.yed)
              `[->- [%rose [" " "~[" "]"] ->+]]
        ==
      ::
      ++  path
        ?-  -.inp
          %&  `[sen [%leaf '/' ~]]
          %|  =+  res=(deck ;;((^list *) q.p.inp) [%atom %tas ~])
              =+  (turn ->+ |=(lef=tank ?>(?=([%leaf *] lef) [%leaf +.p.lef])))
              `[-.+.res [%rose [['/' ~] ['/' ~] ~] -]]
          ==
      :: 
      ++  tape
        ?-  -.inp
          %&  `[sen [%leaf '"' '"' ~]]
          %|  `[sen [%leaf (dash (^tape q.p.inp) '"' "\{")]]
        ==
      ::
      ++  wain
        ?-  -.inp
          %&  `[sen [%leaf '*' '\'' '\'' ~]]
          %|  =+  (deck ;;((^list *) q.p.inp) [%atom %t ~])
              `[->- [%rose [[' ' ~] ['<' '|' ~] ['|' '>' ~]] ->+]]
        ==
      ::
      ++  wall
        ?-  -.inp
          %&  `[sen [%leaf '*' '"' '"' ~]]
          %|  =+  (deck ;;((^list *) q.p.inp) -:!>(*(^list ^tape)))
              `[->- [%rose [[' ' ~] ['<' '<' ~] ['>' '>' ~]] ->+]]
        ==
      ::
      ++  tree
        ?>  ?=([%fork *] typ)
        =+  yed=(sort ~(tap in p.typ) aor)
        ?>  ?=([* [%cell [%face *] *] ~] yed)
        =+  typ=~(repo ut +<+<+>.yed)
        ?-  -.inp
          %&  =+  (disc inp(p typ) sen)
              ?~  -  ~
              `[->- [%rose [" " "(tree " ")"] [->+ ~]]]
          %|  (disc inp(p.p ^typ) sen)  ::  TODO: better tree printing
        ==
      ::
      ++  map
        =+  fok=~(repo ut ~(repo ut typ))
        ?>  ?=([%fork *] fok)
        =+  yed=(sort ~(tap in p.fok) aor)
        ?>  ?=([* [%cell [%face *] *] ~] yed)
        =+  tip=~(repo ut +<+<+>.yed)
        ?>  ?=([%cell [%face *] [%face *]] tip)
        ?-  -.inp
          %&  =+  key=(disc inp(p +<+>:tip) sen)
              ?~  key  ~
              =+  val=(disc inp(p +>+>:tip) sen(q ->.u.key))
              ?~  val  ~
              `[-.u.val [%rose [" " "(map " ")"] [+.u.key +.u.val ~]]]
          %|  =+  (deck ~(tap by ;;((^map * *) q.p.inp)) tip)
              `[->- [%rose [[' ' ~] ['{' ~] ['}' ~]] ->+]]
        ==
      ::
      ++  set
        =+  fok=~(repo ut ~(repo ut typ))
        ?>  ?=([%fork *] fok)
        =+  yed=(sort ~(tap in p.fok) aor)
        ?>  ?=([* [%cell [%face *] *] ~] yed)
        ?-  -.inp
          %&  =+  (disc inp(p +<+<+>.yed) sen)
              ?~  -   ~
              `[-<- [%rose [" " "(set " ")"] [->+ ~]]]
          %|  =+  (deck ~(tap in ;;((^set *) q.p.inp)) +<+<+>.yed)
              `[->- [%rose [[' ' ~] ['{' ~] ['}' ~]] ->+]]
        ==
      ::
      ++  qeu
        =+  fok=~(repo ut ~(repo ut typ))
        ?>  ?=([%fork *] fok)
        =+  yed=(sort ~(tap in p.fok) aor)
        ?>  ?=([* [%cell [%face *] *] ~] yed)
        ?-  -.inp
          %&  =+  (disc inp(p +<+<+>.yed) sen)
              ?~  -  ~
              `[->- [%rose [" " "(qeu " ")"] [->+ ~]]]
          %|  =+  (deck ~(tap to ;;((^qeu *) q.p.inp)) +<+<+>.yed)
              `[->- [%rose [[' ' ~] ['{' ~] ['}' ~]] ->+]]
        ==
      --
    ::
    ++  deck                                            ::  pprint items
      |=  [items=(list *) typ=type]
      :-  ~  %+  reel  items
      |=  [n=* acc=[seen (list tank)]]
      =+  res=(disc [%| [typ n]] -.acc)
      ?~(res acc [-.u.res [+.u.res +.acc]])
    ::
    ++  dash
      |=  [mil=tape lim=char lam=tape]
      ^-  tape
      =/  esc  (~(gas in *(set @tD)) lam)
      :-  lim
      |-  ^-  tape
      ?~  mil  [lim ~]
      ?:  ?|  =(lim i.mil)
              =('\\' i.mil)
              (~(has in esc) i.mil)
          ==
        ['\\' i.mil $(mil t.mil)]
      ?:  (lte ' ' i.mil)
        [i.mil $(mil t.mil)]
      ['\\' ~(x ne (rsh 2 i.mil)) ~(x ne (end 2 i.mil)) $(mil t.mil)]
    --
  --
--
