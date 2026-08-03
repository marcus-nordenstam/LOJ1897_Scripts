; ----------------------------------------------------------------------------
; coercion_pressure.hs - the coerced party's own dread (VICTIM-POV, self-mind).
;
; The victim holds the standing {?blackmailer extort @self} anchor his coercer's
; press keeps refreshing (perpetration_macros coerce-* land it, coercion.hs
; press-coercion refreshes it). Each month he mints + COMPOUNDS his OWN
; exposure_risk pressure toward the blackmailer: begin-belief /cause the anchor
; (so a live cause keeps it off the orphan-sweep) and /salience the class-scaled
; stake (accumulate-on-reuse escalates it in place, walking him from bribe /
; confess toward the kill tail - deliberate_think turns the standing pressure into
; the actual bribe / confess_letter / flee / silence-the-witness action).
;
; NO telepathy / no cross-mind: he role-casts the blackmailer from his OWN extort
; belief and mints only in his OWN mind. When the coercer gives up, the anchor
; stops refreshing and decays out - the role stops binding, the dread fades.
;
; The (when (chance ...)) is the RE-ARM: a permanent-role cooldown event needs a
; (when) that FALLS to cease the bout and re-arm the monthly cooldown (this branch
; predates (cease-after-fire)); most months the dread re-surfaces and compounds.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think coercion_pressure
  (cooldown 1 m)
  (rng-stream perpetration)
  (role @self (adult @self))
  (role ?blackmailer (any_human ?blackmailer)
                     (believes {?blackmailer extort @self}))
  (when (chance 0.5))
  (effects
    (begin-belief {@self pressure [k exposure_risk] ?blackmailer}
                  /cause {?blackmailer extort @self}
                  /salience (coercion-stake))))
