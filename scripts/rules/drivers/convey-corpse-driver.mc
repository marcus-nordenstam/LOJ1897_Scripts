; ----------------------------------------------------------------------------
; convey-corpse - a grown, decent man who has seen a body not yet buried resolves to carry it
; to a church, where a co-present priest perceives it (BURY): the corpse in the church is the
; "bury me" marker, no tell and no cross-mind write. He holds to it until the body is
; delivered (his CONVEY memory drops it from the cast) or the death is months old. While he
; knows no church he searches for one - the task assumes one.
; ----------------------------------------------------------------------------

; The corpse is cast off the ongoing {?corpse condition dead} belief alone: learning a death
; end-dates the observer's {?corpse isa [k human]} belief.
(driver want-convey
  (role @self {@self politeness ?politeness}
              {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (role ?corpse {?corpse condition [k dead]}
                  {?corpse internment [k unburied]}
                  -{@self CONVEY ?corpse /past}
                  (select (score (months-since-death ?corpse)) (policy argmax))
      (when (and (observed ?corpse)
                 (>= ?politeness 0.3)
                 (< (months-since-death ?corpse) 6)))
      (declare-utility want (* 10.0 ?politeness 85.0))
      (stable-or
        (try
          (no-role [k church-building])
          (when -{@self find-building [k church-building] ? /fail})
          (effects (maintain-proposal {@self find-building [k church-building] (current-exterior @self)})))
        (try
          (role ?church [k church-building] (select (policy first-match))
            (effects (maintain-proposal {@self convey-corpse ?corpse}))))))))
