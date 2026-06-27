; ----------------------------------------------------------------------------
; rehabilitation (Phase 9.3). An NPC with a poor respectability_situation
; (disreputable) gets an elevated chance to perform a positive behaviour -
; here, churchgoing - which the F3 piety classifier reads and which the
; respectability classifier in turn fuses into the score. Combined with the
; classification tables' time-decay (Phase 8's act-record ageing), the
; situation can recover slowly over several years.
;
; Why disreputable not scandalous: the scandalous NPC is already ostracised
; (the social door is shut) and a single church visit cannot lift them back
; to respectable in one pass. The disreputable can rehabilitate; the
; scandalous needs a longer, multi-year recovery the time-decay handles.
;
; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
; (per-individual, situation-conditional). MONTHLY now, so the (chance) is /12
; (0.6 -> 0.05) to hold the annual rehabilitation rate (still well above the
; baseline churchgoing rate so the situation has a real shot at climbing).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event rehabilitation
  (long-term-think)
  (rng-stream behaviour)

  (roles
    (role @self (template old_human)))

  ;; A disreputable adult with a personality lift toward conformity
  ;; (politeness) tries the church door. situation / attr / chance are
  ;; non-belief ops, so they gate the fire in (when), not role selection.
  (when (and (= (situation @self repute) [k disreputable])
             (chance (* 0.05 (+ 0.5 (attr @self politeness))))))

  (effects
    (go-to-church @self)
    ))
