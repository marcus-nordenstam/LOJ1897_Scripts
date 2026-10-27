; c02 three - two men and one woman under one roof, the house's supper hour unknown: each man
; hails her to ask it. The hails come at once, each opening a talk of its own; she takes one
; up, and the other man follows her into that talk, or is declined and hails again into it, so
; one talk holds three. Every mind knows the other two as parties of its own copy of the one
; talk. Seeds state only; the validate func reads.

(include "conversation.mc")

(define-list config
  seeds 4242 4243
  start 1700-01-01
  end 1700-01-31
  clock jump
  level "Theatres/demo_tech_level_v2.grs"
  startup c02-startup)

(define-list gauntlet validate c02-validate)

(define-func c02-startup ()
  (seed_property)
  (conversation-first-home): ?home
  (make-human ?home [k lower] [k male]): ?first
  (cast first ?first)
  (make-human ?home [k lower] [k male]): ?second
  (cast second ?second)
  (make-human ?home [k lower] [k female]): ?cook
  (cast cook ?cook)
  (initialize-minds)
  (wed-founders))

(define-func c02-validate ()
  (cast first): ?first
  (cast second): ?second
  (cast cook): ?cook
  (expect (> (+ (acts ?first hail succ) (acts ?second hail succ)) 1) "c02: fewer than two hails taken up")
  (expect (> (acts ?cook take-up succ) 0) "c02: she never took anyone up")
  (expect (in-mind ?cook (knows-talk-with ?first ?second)) "c02: she does not know three in one talk")
  (expect (in-mind ?first (substantial (any {? participant ? /ever}))) "c02: the first knows no talk")
  (expect (in-mind ?second (substantial (any {? participant ? /ever}))) "c02: the second knows no talk")
  (expect (unsubstantial (bb-public-read ?cook conversing)) "c02: her entry still names a talk")
  (expect (in-mind ?cook (= (spoken-over) 0)) "c02: two men spoke to her at once"))
