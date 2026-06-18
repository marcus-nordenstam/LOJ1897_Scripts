; ----------------------------------------------------------------------------
; social_ostracism (Phase 9.3). An NPC whose respectability_situation has
; fallen to `scandalous` is cut off: every warmth bond (friend / close_to) is
; ended bidirectionally and every club membership is resigned. relied_on_by /
; respected_by survive (utility bonds outlast the social door closing - a man
; widely consulted in business is still consulted while shunned at parties),
; employer / family bonds survive (ostracism is social, not vocational or
; filial). The Victorian "social death" - distinct from a clean rupture.
;
; The verb itself is unconditional; the event gates on the situation. Idempotent:
; an already-ostracised NPC has no warmth bonds left and the verb is a no-op
; after the first firing. A held-friend gate would short-circuit subsequent
; passes but adds engine work to test - the no-op cost is bounded by the
; small per-NPC bond count, so we skip the gate.
;
; Schedule: annually october (after the betrothal / wedding / engagement_party
; chain and the september behaviour events have run, so a respectability fall
; mid-year is still visible to those events the same year).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event social_ostracism
  (nl         "?npc is ostracised")
  ; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
  ; MONTHLY. social-ostracism is idempotent (re-ending already-ended warmth bonds /
  ; club memberships is a no-op), but to avoid 12x/year log + scan churn the role
  ; carries (chance 0.0833) ~= the old annual cadence; a scandalous NPC is
  ; ostracised ~once a year (and re-ostracised if they form new warmth ties).
  (rng-stream behaviour)

  (roles
    (role ?npc (template old_human)
               (= (situation ?this repute) [k scandalous])
               (chance 0.0833)))

  (effects
    (social-ostracism ?npc)
    (log _ostracism ?npc)))
