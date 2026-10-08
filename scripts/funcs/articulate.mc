; ----------------------------------------------------------------------------
; (articulate ?thing ?amount) - move an articulated part to ?amount in 0..1 of open: a movable
; barrier swings about its hinge-side edge through swing-angle degrees, a drawer slides out
; through drawer-travel of its depth. Writes open-amount and the pose and nothing else: the act
; that moves the part writes its opening-status when it concludes. Called from the effects of
; OPEN, CLOSE and FORCE-ENTRY.
; ----------------------------------------------------------------------------

; A double-door holds still as its passage's throat while its door-leaf parts swing, each by its
; own hinge-side and swing-angle.
(define-func articulate (?thing ?amount)
  (cond (case (is-a ?thing [k drawer])
              (slide ?thing ?amount (attr ?thing drawer-travel)))
        (case (is-a ?thing [k double-door])
              (for-each ?leaf (spatial ?thing parts [k door-leaf] /env)
                (swing ?leaf ?amount (attr ?leaf hinge-side) (attr ?leaf swing-angle))))
        (else (swing ?thing ?amount (attr ?thing hinge-side) (attr ?thing swing-angle))))
  (set-attr ?thing open-amount ?amount))

; ?thing swings or slides: a movable barrier or a drawer.
(define-func articulated (?thing)
  (or (is-a ?thing [k door]) (is-a ?thing [k window]) (is-a ?thing [k drawer])))
