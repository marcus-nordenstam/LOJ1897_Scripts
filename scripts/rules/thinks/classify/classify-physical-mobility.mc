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

(think classify-physical-mobility
  (rng-stream behaviour)

  (and
    (try
      (role @self {@self condition [k dead]} {@self physical-mobility ?}
        (effects (end-belief {@self physical-mobility ?}))))
    (try
      (role @self {@self condition ?} -{@self condition [k dead]}
        (effects
          (begin-belief {@self physical-mobility
            (flip {@self awareness [k unconscious]} [k bedridden] [k mobile])}))))))
