; ----------------------------------------------------------------------------
; Births. PER-NPC: a birth happens to a specific woman, not to the world. So it
; runs in the (long-term-think) window-start pass with @self bound to each living
; NPC; the fertile_wife template gates @self down to a married woman of fertile
; age, and a per-month (chance) rolls the conception. No role casting.
;
; The husband is recovered from @self's OWN spouse belief (no second role): the
; free ?husband in (believes {@self spouse ?husband}) binds to her spouse.
;
; (birth-human ...) wraps mx_make_entity + mx_make_human: it creates the child,
; samples traits Mendelian from mother + father, and asserts bio_parent_of in
; both parents' minds. The new child is appended to the env, not to this pass's
; pre-collected agent list, so it is not iterated mid-pass (safe).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour birth
  (long-term-think)
  (rng-stream births)

  (roles
    (role @self (template fertile_wife)))

  ; chance first (cheap, short-circuits), then bind the husband from her spouse
  ; belief - ~0.40 per couple-year over 12 monthly rolls.
  (when (and (chance 0.033)
             (believes {@self spouse ?husband})))

  (effects
    (birth-human /mother @self /father ?husband)
    ))
