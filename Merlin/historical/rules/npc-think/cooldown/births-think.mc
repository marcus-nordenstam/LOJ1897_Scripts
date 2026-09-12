; ----------------------------------------------------------------------------
; The two ends of a pregnancy, as DELIBERATION: deciding to lie with a husband,
; and deciding that the child is due. Neither touches the world - the pregnancy
; is stamped by the HAVE-SEX-WITH action that causes it, and the child is borne
; by the GIVE-BIRTH action. A think only ever proposes.
;
;   marital_coupling - a married, fertile-age woman not already carrying a
;       pregnancy takes her husband to bed. Whether that conception TAKES is not
;       her decision and not this rule's business: HAVE-SEX-WITH rolls it, for a
;       wife and a paramour alike, which is why an affair can produce a child
;       without a second rule anywhere.
;   deliver - she has carried the pregnancy its full term, so the child is due.
;       The father comes off her own {@self pregnant ?} belief and rides the act
;       pattern, so GIVE-BIRTH does no reading of its own.
;
; The term is measured against pregnant-when, which is her own self-belief (every
; self-attr is mirrored as one) - never an attr read, which would be outside the
; wake plane.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

; Per-month odds that a fertile wife and her husband share a bed at all, and the
; odds that a coupling takes. Their product is the monthly conception rate.
(define-macro marital_coupling_chance () 0.5)

(npc-think marital_coupling
  (cooldown 1 m)
  (rng-stream births)

  ; a married, fertile-age woman not already carrying a pregnancy (fertile_wife
  ; folds in the not-pregnant gate)
  (role @self (fertile_wife @self))

  ; her husband, and under the same roof - a coupling needs both bodies present.
  (role ?husband {@self spouse ?husband}
                 (spatial ?husband co-located-building @self))

  (when (chance (marital_coupling_chance)))

  (utility want)

  (effects
    (maintain-proposal {@self HAVE-SEX-WITH ?husband})))

; The child is due. A woman at term bears it ahead of any errand - labour is not
; something she chooses to postpone - but below the survival lanes.
(npc-think deliver
  (cooldown 1 d)

  (role @self {@self pregnant ?})
  (role ?father {@self pregnant ?father})

  (any {@self pregnant-when ?}).target: ?conceived-when

  (when (>= (time-since /weeks ?conceived-when) (gestation_weeks)))

  (utility need)

  (effects
    (maintain-proposal {@self GIVE-BIRTH ?father})))
