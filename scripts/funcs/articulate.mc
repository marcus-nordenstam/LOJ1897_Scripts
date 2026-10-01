; ----------------------------------------------------------------------------
; (articulate ?thing ?amount) - set an articulated part's opening to ?amount in 0..1 and move
; its box to match: an opening swings about its hinge-side edge through swing-angle degrees,
; a drawer slides out through drawer-travel of its depth. Writes open-amount and
; opening-status (ajar above zero, else shut) here and nowhere else, so the attrs and the
; geometry cannot disagree. Called from the effects of OPEN and CLOSE.
; ----------------------------------------------------------------------------

(define-func articulate (?thing ?amount)
  (if (is-a ?thing [k opening])
      (then (swing ?thing ?amount (attr ?thing hinge-side) (attr ?thing swing-angle)))
      (else (slide ?thing ?amount (attr ?thing drawer-travel))))
  (set-attr ?thing open-amount ?amount)
  (set-attr ?thing opening-status (if (> ?amount 0.0) (then [k ajar]) (else [k shut]))))
