; ----------------------------------------------------------------------------
; physical-mobility (classifier). The observable locomotion level as
; {@self physical-mobility mobile|bedridden} - what an NPC can DO physically,
; distinct from `alertness` (sleep/wake), `condition` (alive/dead) and `awareness`
; (conscious/unconscious). Read by the occasion gates (occasion-macros.mc), which
; excuse a bedridden NPC from attending.
;
; @excl, so a re-assert at a different level ends the prior one; a same-level
; re-assert dedups. A corpse carries no locomotion state at all, so the dead
; branch ENDS the belief rather than banding it.
;
; The crutch-assisted / wheelchair-bound leaves are declared but unused: the old
; C++ fold only ever produced mobile / bedridden, and this is a faithful port of
; it. They want an injury-severity input before they can be minted.
; ----------------------------------------------------------------------------

(npc-think classify_physical_mobility
  (rng-stream behaviour)

  (role @self {@self condition ?})

  (effects
    (if {@self condition [k dead]}
      (then (end-belief {@self physical-mobility ?}))
      (else
        (begin-belief {@self physical-mobility
          (if {@self awareness [k unconscious]}
            (then [k bedridden])
            (else [k mobile]))})))))
