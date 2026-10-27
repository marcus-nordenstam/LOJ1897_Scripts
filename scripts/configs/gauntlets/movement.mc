; ----------------------------------------------------------------------------
; movement - the movement gauntlet: four men, four journeys, each raised by a driver the corpus
; already has and judged by what the run profile counted and what each man came to know. The
; funcs are written once here and included by one config per clock: movement-jump.mc (the
; windows, several seeds) and movement-real.mc (the real clock, one day, presented round the
; regular). Seeds state only - nothing here proposes (mlint gauntlet-purity).
;
;   regular    - thirsty, taught the first pub by sight: locate-room -> go-to across town, out of
;                his home by its door and into the pub by its door -> DRINK. The plain journey.
;   explorer   - thirsty, knows only his home: find-building surveys the town until a pub is
;                seen, then the regular's journey. Discovery.
;   locked-out - thirsty, taught the second pub, whose every door is locked: the WALK stops
;                before the door, the cross fails, the go-to fails, locate-room gives that pub up
;                and find-building finds him another. The world barring a believed way.
;   homebody   - worn out, stood in the street outside his home: go-to-bed takes him home,
;                through its door, into a bedroom, and he sleeps. Into an enclosure from outside.
; ----------------------------------------------------------------------------

(include "../../macros/physiology-macros.mc")

; The n-th residential building that holds a unit, 0-based, as its unit: a chapel is a
; residential building too, and has none.
(define-func movement-nth-home (?n)
  (bind @nothing ?home)
  (bind 0 ?seen)
  (for-each ?house (env-entities [k residential-building])
    (head (spatial ?house parts [k unit] /env)): ?unit
    (if (substantial ?unit)
        (then (if (= ?seen ?n) (then (bind ?unit ?home) (break)))
              (bind (+ ?seen 1) ?seen))))
  (check (substantial ?home))
  ?home)

; He has seen ?thing: it is in his mind as a thing of its kind, with its box.
(define-func movement-teach (?man ?thing)
  (enter-mind ?man)
  (observe ?thing)
  (exit-mind))

(define-func movement-lock-doors (?building)
  (for-each ?door (spatial ?building exits /env)
    (set-attr ?door lock-status [k locked])))

(define-func movement-startup ()
  (seed_property)
  (env-entities [k pub-building]): ?pubs
  (check (> (count ?pubs) 1))
  (nth 0 ?pubs): ?first-pub
  (nth 1 ?pubs): ?second-pub

  (movement-nth-home 0): ?regular-home
  (make-human ?regular-home [k lower] [k male]): ?regular
  (cast regular ?regular)
  (movement-teach ?regular ?first-pub)

  (movement-nth-home 1): ?explorer-home
  (make-human ?explorer-home [k lower] [k male]): ?explorer
  (cast explorer ?explorer)

  (movement-nth-home 2): ?locked-out-home
  (make-human ?locked-out-home [k lower] [k male]): ?locked-out
  (cast locked-out ?locked-out)
  (movement-teach ?locked-out ?second-pub)
  (movement-lock-doors ?second-pub)

  (movement-nth-home 3): ?homebody-home
  (make-human ?homebody-home [k lower] [k male]): ?homebody
  (cast homebody ?homebody)
  (set-attr ?homebody fatigue (fatigue_max))
  (spatial ?homebody-home building /env): ?homebody-house
  (spatial ?homebody-house space /env): ?street
  (check (is-a ?street [k exterior-space]))
  (relocate ?homebody (travel-spot ?street))

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
  (expect (> (acts ?locked-out go-to fail) 0) "locked-out: the go-to to the locked pub never failed")
  (expect (> (acts ?locked-out find-building succ) 0) "locked-out: never found another pub")
  (expect (> (acts ?locked-out DRINK succ) 0) "locked-out: never drank")

  (cast homebody): ?homebody
  (expect (> (acts ?homebody go-to succ) 0) "homebody: no go-to succeeded")
  (expect (> (acts ?homebody enter-room succ) 0) "homebody: never reached a bedroom")
  (expect (> (acts ?homebody SLEEP started) 0) "homebody: never slept")

  (if (real-clock)
      (then (expect (in-mind ?regular (presented-lod)) "regular: not presented under the real clock"))))
