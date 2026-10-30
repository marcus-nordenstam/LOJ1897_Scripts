; ----------------------------------------------------------------------------
; movement - the movement gauntlet: four men, four journeys, each raised by a driver the corpus
; already has and judged by what the run profile counted and what each man came to know. The
; funcs are written once here and included by one config per clock: movement-jump.mc (the
; windows, several seeds) and movement-real.mc (the real clock, one day, presented round the
; regular). Seeds state only - nothing here proposes (mlint gauntlet-purity).
;
;   regular    - thirsty, taught his own town's pub by sight: locate-room -> enter-building, out
;                of his home by its door, beside the pub, into it by its door -> DRINK. The plain
;                journey.
;   explorer   - thirsty, knows only his home: find-building surveys his town until its pub is
;                seen, then the regular's journey. Discovery.
;   locked-out - thirsty, in another town, taught its pub, whose every door is locked: the WALK
;                stops before the door, the cross fails, entering the pub fails, and he never drinks.
;                The world barring a believed way.
;   homebody   - worn out, stood in the street outside his home: go-to-bed takes him home,
;                through its door, into a bedroom, and he sleeps. Into an enclosure from outside.
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

(define-func movement-startup ()
  (seed_property)
  (spatial (head (env-entities [k pub-building])) space /env): ?town
  (movement-other-pub-town ?town): ?locked-town

  (movement-nth-home ?town 0): ?regular-home
  (make-human ?regular-home [k lower] [k male]): ?regular
  (cast regular ?regular)
  (movement-teach ?regular (movement-town-pub ?town))

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

  (initialize-minds))

; Every journey is over: each man has done what his journey ends in - the locked-out man's ends
; at the locked door. The run stops there, and movement-validate judges how he got there.
(define-func movement-done ()
  (and (> (acts (cast regular) DRINK succ) 0)
       (> (acts (cast explorer) DRINK succ) 0)
       (> (acts (cast locked-out) enter-building fail) 0)
       (> (acts (cast homebody) SLEEP started) 0)))

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
  (expect (> (acts ?locked-out enter-building fail) 0) "locked-out: entering the locked pub never failed")
  (expect (= (acts ?locked-out DRINK succ) 0) "locked-out: drank in a town whose only pub is locked")

  (cast homebody): ?homebody
  (expect (> (acts ?homebody enter-room succ) 0) "homebody: never entered a room of his home")
  (expect (> (acts ?homebody cross succ) 0) "homebody: never came in through a door")
  (expect (> (acts ?homebody SLEEP started) 0) "homebody: never slept")

  (if (real-clock)
      (then (expect (in-mind ?regular (presented-lod)) "regular: not presented under the real clock"))))
