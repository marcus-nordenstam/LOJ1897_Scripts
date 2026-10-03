; ----------------------------------------------------------------------------
; (articulate ?thing ?amount) - move an articulated part to ?amount in 0..1 of open: a movable
; barrier swings about its hinge-side edge through swing-angle degrees, a drawer slides out
; through drawer-travel of its depth. Writes open-amount and the pose and nothing else: the act
; that moves the part writes its opening-status when it concludes. Called from the effects of
; OPEN, CLOSE and FORCE-ENTRY.
; ----------------------------------------------------------------------------

(define-func articulate (?thing ?amount)
  (if (is-a ?thing [k movable-barrier])
      (then (swing ?thing ?amount (attr ?thing hinge-side) (attr ?thing swing-angle)))
      (else (slide ?thing ?amount (attr ?thing drawer-travel))))
  (set-attr ?thing open-amount ?amount))

; ?thing swings or slides: a movable barrier or a drawer.
(define-func articulated (?thing)
  (or (is-a ?thing [k movable-barrier]) (is-a ?thing [k drawer])))
