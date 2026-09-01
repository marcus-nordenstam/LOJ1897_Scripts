; ----------------------------------------------------------------------------
; coercion_pressure.hs - the coerced party's own dread (VICTIM-POV, self-mind).
;
; The victim holds the standing {?blackmailer extort @self} anchor his coercer's
; press keeps refreshing (perpetration_macros coerce-* land it, coercion.hs
; press-coercion refreshes it). Each month he mints + COMPOUNDS his OWN
; exposure-risk pressure toward the blackmailer: begin-belief /caused_by the anchor
; (so a live cause keeps it off the orphan-sweep) and (salience ..) the class-scaled
; stake (accumulate-on-reuse escalates it in place, walking him from bribe /
; confess toward the kill tail - deliberate_think turns the standing pressure into
; the actual bribe / confess-letter / flee / silence-the-witness action).
;
; NO telepathy / no cross-mind: he role-casts the blackmailer from his OWN extort
; belief and mints only in his OWN mind. When the coercer gives up, the anchor
; stops refreshing and decays out - the role stops binding, the dread fades.
;
; (cease-after-fire) makes it a clean monthly PULSE: (adult @self) never falls, so
; the bout would otherwise hold after the first fire and never re-mint; ceasing on
; fire lets the 1-month cooldown re-arm it, so the exposure-risk pressure compounds
; every month the extort anchor still stands.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think coercion_pressure
  (cooldown 1 m)
  (cease-after-fire)
  (rng-stream perpetration)
  (role @self (adult @self))
  (role ?blackmailer (any_human ?blackmailer)
                     {?blackmailer extort @self})
  (effects
    (begin-belief {?blackmailer extort @self}): ?extort_anchor
    (begin-belief {@self pressure [k exposure-risk] ?blackmailer /caused_by ?extort_anchor}
                  [/salience (coercion-stake)])))
