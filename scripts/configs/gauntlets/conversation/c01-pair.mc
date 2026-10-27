; c01 pair - a husband and wife under one roof, the house's supper hour unknown: ask-mealtimes
; has him hail her, she takes him up, he asks and she answers, and he takes his leave. His
; converse ends the instant her answer lands, its driver no longer wanting it, and the leave
; it begins on ceasing is what closes the talk. ONE conversation: each holds his own talk, both
; in it, with a venue that opens and closes; when it is over nobody's entry names it. Seeds
; state only; the validate func reads.

(define-list config
  seeds 4242 4243
  start 1700-01-01
  end 1700-01-31
  clock jump
  level "Theatres/demo_tech_level_v2.grs"
  startup c01-startup)

(define-list gauntlet validate c01-validate)

(include "conversation.mc")

(define-func c01-startup ()
  (seed_property)
  (conversation-first-home): ?home
  (make-human ?home [k lower] [k male]): ?opener
  (cast opener ?opener)
  (make-human ?home [k lower] [k female]): ?hailed
  (cast hailed ?hailed)
  (initialize-minds)
  (wed-founders))

(define-func c01-validate ()
  (cast opener): ?opener
  (cast hailed): ?hailed
  (expect (> (acts ?opener hail succ) 0) "c01: the hail was never taken up")
  (expect (> (acts ?hailed take-up succ) 0) "c01: she never took him up")
  (expect (> (acts ?opener converse started) 0) "c01: his exchange never began")
  (expect (in-mind ?opener (unsubstantial (any {@self converse ?}))) "c01: his exchange never ended")
  (expect (>= (acts ?hailed tell succ) 2) "c01: she never answered him")
  (expect (left-talk ?opener) "c01: he never took his leave")
  (expect (in-mind ?opener (substantial (any {? participant @self /ever}))) "c01: he knows no talk he was in")
  (expect (in-mind ?hailed (substantial (any {? participant @self /ever}))) "c01: she knows no talk she was in")
  (expect (in-mind ?opener (substantial (any {? participant ? /past}))) "c01: his part in the talk never ended")
  (expect (in-mind ?hailed (substantial (any {? participant ? /past}))) "c01: her part in the talk never ended")
  (expect (in-mind ?opener (substantial (any {? venue ? /past}))) "c01: the talk's venue never closed")
  (expect (unsubstantial (bb-public-read ?opener conversing)) "c01: his entry still names a talk")
  (expect (unsubstantial (bb-public-read ?hailed conversing)) "c01: her entry still names a talk"))
