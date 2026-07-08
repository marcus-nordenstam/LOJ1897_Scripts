; worship - the churchgoing lane in the B4 think -> act-goal -> act-behaviour model.
; Desire (feel_devout) mints the standing {@self goal worship} aim in
; npc-think/feel_devout.hs. THIS file turns that aim into acts.
;
;   worship_think (npc-think): each intra-day pass, reads the aim + precondition
;     and mints the RIGHT act-goal - a `go` sub-act when not at a church (the
;     derived precondition act), or the `worship` act when there. Both carry
;     utility 30; act-selection sums + promotes the winner.
;   worship_act (npc-act): implements the worship act. Self-targeted act-belief
;     ({@self worship @self}); on completion it mints the church-targeted standing
;     piety marker {@self worship <church>} the classifier reads, ends the aim
;     (so worship_think stops proposing), and ends its own act (fire-once).
;   go_act (npc-act): the generic travel act-body - relocate to the destination,
;     duration = the one-way travel time (the primitive clock, not engine-baked).

(include "../../definitions/roles.hs")

(npc-think worship_think
  (short-term-think)
  (when (has-goal worship))
  (utility 30)
  (effects
    (if (at-place-kind [k building church])
        (begin-goal {@self worship})                          ; at church -> the act
        (do (bind (venue [k building church]) ?go_dest)       ; else -> the go sub-act
            (if (is-entity ?go_dest)
                (begin-goal {@self go ?go_dest}))))))

(npc-act worship_act
  (when (believes {@self worship @self}))
  (duration 90)
  (effects
    ; The standing piety marker the classifier reads, minted about the church the
    ; churchgoing lane actually travelled the NPC to (real co-presence).
    (bind (current-building @self) ?church)
    (if (is-entity ?church)
        (begin-belief {@self worship ?church}))
    (end-goal {@self worship})            ; the aim is discharged - worship_think ceases
    (end-act {@self worship @self})))     ; end the act-belief -> fire-once

(npc-act go_act
  (when (believes {@self go ?dest}))
  (duration (travel-minutes @self ?dest))
  (effects
    (relocate @self ?dest)
    (end-goal {@self go})                 ; the trip is done - drop the go aim
    (end-act {@self go ?dest})))          ; end the act-belief -> fire-once
