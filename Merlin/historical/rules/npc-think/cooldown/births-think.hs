; ----------------------------------------------------------------------------
; Conception. PER-NPC: a married, fertile-age woman who is not already carrying a
; pregnancy rolls a monthly conception (chance). On success she records the
; pregnancy the isim way - the pregnant_when / pregnant_by physiological attrs
; (the same attrs HAVE_SEX_WITH sets) - plus a {@self pregnant ?husband}
; self-belief that gates her out of re-conceiving until she delivers.
;
; DELIVERY is NOT here: update_physiology (hse_engine.cc) runs the ~9-month
; gestation timer off pregnant_when, births the child of her + pregnant_by, and
; clears the pregnancy. So this file is the conception half; the physiology sim
; owns the birth half.
;
; The husband is recovered from @self's OWN spouse belief (no second role): the
; free ?husband in (any {@self spouse ?husband}) binds to her spouse.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think conceive
  (cooldown 1 m)
  (rng-stream births)

  ; a married, fertile-age woman not already carrying a pregnancy (fertile_wife
  ; folds in the not-pregnant gate)
  (role @self (fertile_wife @self))

  ; chance first (cheap, short-circuits), then bind the husband from her spouse
  (when (and (chance 0.05)
             (any {@self spouse ?}).target: ?husband))

  (effects
    (set-attr @self pregnant_when (date-now))
    (set-attr @self pregnant_by ?husband)
    (begin-belief {@self pregnant ?husband})))
