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

(include "../../../definitions/roles.hs")

(npc-think social_ostracism
  ; Per-NPC (schedule cooldown 1 m), MONTHLY. social-ostracism is idempotent (re-ending
  ; already-ended warmth bonds / club memberships is a no-op); the (chance 0.0833)
  ; ~= an annual cadence so a scandalous NPC is ostracised ~once a year (and
  ; re-ostracised if they form new warmth ties). The scandal gate reads the
  ; {@self repute <band>} self-belief the derive pass maintains alongside the
  ; situation op (hsim_derive mints it each window) - a CACHED self-gate filter,
  ; so the non-scandalous town empty-set-skips. chance stays in (when).
  (schedule cooldown 1 m)
  (rng-stream behaviour)

  (role @self (old_human @self)
              (believes {@self repute [k scandalous]}))

  (when (chance 0.0833))

  (effects
    (social-ostracism @self)
    ))
