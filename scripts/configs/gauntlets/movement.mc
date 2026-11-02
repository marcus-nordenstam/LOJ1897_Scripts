; ----------------------------------------------------------------------------
; movement - the movement gauntlet: four men, four journeys, each raised by a driver the corpus
; already has and judged by what the run profile counted and what each man came to know. The
; funcs are written once here and included by one config per clock: movement-jump.mc (the
; windows, several seeds) and movement-real.mc (the real clock, one day, presented round the
; regular). Seeds state only - nothing here proposes (mlint gauntlet-purity).
;
;   regular    - thirsty, taught his own town's pub by sight: enter-room-kind -> enter-building, out
;                of his home by its door, beside the pub, into it by its door -> DRINK. The plain
;                journey.
;   explorer   - thirsty, knows only his home: find-building surveys his town until its pub is
;                seen, then the regular's journey. Discovery.
;   locked-out - thirsty, in another town, taught its pub, whose every door is locked: the WALK
;                stops before the door, the cross fails, entering its bar-room fails, and he never drinks.
;                The world barring a believed way.
;   homebody   - worn out, stood in the street outside his home: go-to-bed takes him home,
;                through its door, into a bedroom, and he sleeps. Into an enclosure from outside.
;   commuter   - on shift all day at the town's pub, which he knows only by the address his job
;                names: no box until he sees it. The work drivers take him there, and he starts work.
; The regular carries an almanac in his hand the whole way: in his own mind its box goes with him.
;
; Every man's pub stands in his own town: a town has one pub, and a journey to another town is
; not what this gauntlet judges.
; ----------------------------------------------------------------------------

(include "../../macros/physiology-macros.mc")

; The n-th residential building in ?town that holds a unit, 0-based, as its unit: a chapel is a
; residential building too, and has none.
(define-func movement-nth-home (?town ?n)
  (bind @nothing ?home)
  (bind 0 ?seen)
  (for-each ?house (env-entities [k residential-building])
    (head (spatial ?house parts [k unit] /env)): ?unit
    (if (and (substantial ?unit) (eq (spatial ?house space /env) ?town))
        (then (if (= ?seen ?n) (then (bind ?unit ?home) (break)))
              (bind (+ ?seen 1) ?seen))))
  (check (substantial ?home))
  ?home)

; The pub standing in ?town.
(define-func movement-town-pub (?town)
  (bind @nothing ?pub)
  (for-each ?candidate (env-entities [k pub-building])
    (if (eq (spatial ?candidate space /env) ?town)
        (then (bind ?candidate ?pub) (break))))
  (check (substantial ?pub))
  ?pub)

; A town with a pub other than ?town.
(define-func movement-other-pub-town (?town)
  (bind @nothing ?other)
  (for-each ?pub (env-entities [k pub-building])
    (spatial ?pub space /env): ?pub-town
    (if (not (eq ?pub-town ?town))
        (then (bind ?pub-town ?other) (break))))
  (check (substantial ?other))
  ?other)

; He has seen ?thing: it is in his mind as a thing of its kind, with its box.
(define-func movement-teach (?man ?thing)
  (enter-mind ?man)
  (observe ?thing)
  (exit-mind))

(define-func movement-lock-doors (?building)
  (for-each ?door (spatial ?building exits /env)
    (set-attr ?door lock-status [k locked])))

(define-func movement-open-doors (?place)
  (for-each ?door (spatial ?place exits /env)
    (if (is-a ?door [k door])
        (then (set-attr ?door opening-status [k ajar])
              (set-attr ?door open-amount 1.0)))))

; ?man holds an almanac in his right hand, and knows he does.
(define-func movement-hand-book (?man)
  (create-entity [k almanac] (find-spot [k almanac] [/at_or_near ?man])): ?book
  (spatial-write ?book gripped-by (spatial ?man right-hand /env) /env)
  (movement-teach ?man ?book))

; He holds a job, on shift all day every day, at an org whose workplace is ?premises's address: the
; premises is in his mind by that address alone.
(define-func movement-employ-at-address (?man ?premises)
  (attr ?premises address): ?address
  (enter-mind ?man)
  (o [k org] {@o name [n Movement Works]}): ?org
  (begin-belief {?org name [n Movement Works]})
  (begin-belief {?org workplace ?address})
  (o [k job] {@o org ?org}): ?job
  (begin-belief {?job org ?org})
  (begin-belief {@self job ?job})
  (begin-belief {?job working-hours (weekly [sunday monday tuesday wednesday thursday friday saturday] #6:00 #22:00)})
  (exit-mind))

; The door of ?place that opens onto ?street: an exit may be a window.
(define-func movement-street-door (?place ?street)
  (bind @nothing ?front)
  (for-each ?door (spatial ?place exits /env)
    (if (and (is-a ?door [k door]) (substantial (spatial ?door beyond ?street /env)))
        (then (bind ?door ?front) (break))))
  (check (substantial ?front))
  ?front)

; ?man stands in ?street, as near ?place's front door as he can.
(define-func movement-stand-before-door (?man ?place ?street)
  (movement-street-door ?place ?street): ?door
  (relocate ?man (find-spot ?man [/on_floor_of ?street] [/near ?door])))

; ?man stands in the room ?place's front door opens into from ?street, as near the door as he can.
(define-func movement-stand-inside-door (?man ?place ?street)
  (movement-street-door ?place ?street): ?door
  (relocate ?man (find-spot ?man [/on_floor_of (spatial ?door beyond ?street /env)] [/near ?door])))

; The man @self knows by ?name.
(define-func movement-known-as (?name)
  (any {? name ?name}).subject)

; What @self believes ?who holds in his right hand.
(define-func movement-right-hand-holds (?who)
  (head (spatial (spatial ?who right-hand) grip)))

(define-func movement-startup ()
  (seed_property)
  (spatial (head (env-entities [k pub-building])) space /env): ?town
  (movement-other-pub-town ?town): ?locked-town

  (movement-nth-home ?town 0): ?regular-home
  (make-human ?regular-home [k lower] [k male]): ?regular
  (cast regular ?regular)
  (movement-teach ?regular (movement-town-pub ?town))
  (movement-hand-book ?regular)

  (movement-nth-home ?town 1): ?explorer-home
  (make-human ?explorer-home [k lower] [k male]): ?explorer
  (cast explorer ?explorer)

  (movement-nth-home ?locked-town 0): ?locked-out-home
  (make-human ?locked-out-home [k lower] [k male]): ?locked-out
  (cast locked-out ?locked-out)
  (movement-town-pub ?locked-town): ?locked-pub
  (movement-teach ?locked-out ?locked-pub)
  (movement-lock-doors ?locked-pub)

  (movement-nth-home ?town 2): ?homebody-home
  (make-human ?homebody-home [k lower] [k male]): ?homebody
  (cast homebody ?homebody)
  (set-attr ?homebody fatigue (fatigue_max))
  (spatial ?homebody-home building /env): ?homebody-house
  (spatial ?homebody-house space /env): ?street
  (check (is-a ?street [k exterior-space]))
  (relocate ?homebody (travel-spot ?street))

  (movement-nth-home ?town 3): ?commuter-home
  (make-human ?commuter-home [k lower] [k male]): ?commuter
  (cast commuter ?commuter)
  (cast workplace (movement-town-pub ?town))
  (movement-employ-at-address ?commuter (movement-town-pub ?town))


  (initialize-minds))

(define-func movement-validate ()
  (cast regular): ?regular
  (expect (> (acts ?regular go-to succ) 0) "regular: no go-to succeeded")
  (expect (> (acts ?regular WALK succ) 1) "regular: fewer than two walks")
  (expect (> (acts ?regular DRINK succ) 0) "regular: never drank")

  (cast explorer): ?explorer
  (expect (> (acts ?explorer find-building succ) 0) "explorer: never found a pub")
  (expect (> (acts ?explorer DRINK succ) 0) "explorer: never drank")

  (cast locked-out): ?locked-out
  (expect (> (acts ?locked-out cross fail) 0) "locked-out: no cross failed at the locked door")
  (expect (> (acts ?locked-out enter-room-kind fail) 0) "locked-out: entering the locked pub never failed")
  (expect (= (acts ?locked-out DRINK succ) 0) "locked-out: drank in a town whose only pub is locked")

  (cast homebody): ?homebody
  (expect (> (acts ?homebody enter-room succ) 0) "homebody: never entered a room of his home")
  (expect (> (acts ?homebody cross succ) 0) "homebody: never came in through a door")
  (expect (> (acts ?homebody SLEEP started) 0) "homebody: never slept")

  (expect (in-mind ?regular (< (distance (movement-right-hand-holds @self) @self) 1.0))
          "regular: the almanac in his hand stayed behind in his mind when he walked")

  (cast commuter): ?commuter
  (expect (> (acts ?commuter work started) 0) "commuter: never started work at the workplace he knew by its address")
  (attr (cast workplace) address): ?workplace-address
  (expect (in-mind ?commuter (substantial (seen-premises-at ?workplace-address)))
          "commuter: never saw the premises at his workplace's address")


  (if (real-clock)
      (then (expect (in-mind ?regular (presented-lod)) "regular: not presented under the real clock"))))
