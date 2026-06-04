; ----------------------------------------------------------------------------
; Births. For each fertile married woman, with a small monthly chance,
; spawn a child whose father is recovered via her spouse belief.
;
; The (birth-human ...) verb wraps mx_make_entity + mx_make_human - it creates
; a new entity, populates traits via Mendelian sampling from mother + father,
; and asserts the bio_parent_of beliefs in both parents' minds. This event
; therefore only needs to identify the couple and trigger the verb.
;
; Topology: ?wife is enumerated; ?husband is recovered through the
; (believes ?wife {@self spouse ?husband}) relational filter.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event birth
  (nl         "?wife and ?husband have a child")
  (kind       _birth)
  (schedule   (monthly))
  (rng-stream births)

  (roles
    ;; Per-wife per-month roll happens before husband recovery so we don't
    ;; pay the belief query unless this couple is actually conceiving.
    (role ?wife    (template fertile_wife)
                   (chance 0.033))   ; ~0.40 per couple-year over 12 months
    (role ?husband (template any_human)
                   (= (attr ?self gender) male)
                   (believes ?wife {@self spouse ?husband})))

  (effects
    (birth-human :mother ?wife :father ?husband)
    (log _birth ?wife)))
