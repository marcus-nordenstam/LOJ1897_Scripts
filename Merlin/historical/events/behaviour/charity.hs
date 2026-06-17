; ----------------------------------------------------------------------------
; charity - a Phase 8 behaviour seed event. Each year a few adults perform an
; act of charity, gaining a {@self give <alms>} act-record - the alms a number
; symbol, the sum given. The F3.5 generosity classifier reads it. Binary,
; like gambling: one act-record marks the NPC a giver, and the (not (believes
; ...)) gate fires the onset at most once per NPC. Reuses the existing `give`
; task label - hsim runs in historic mode, where the action-pipeline guard
; that normally rejects a directly-asserted self-subject task-belief is
; skipped (sim/sim_mode.h).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
; (per-individual, compassion-weighted), MONTHLY now, so the (chance) is /12
; (0.008 -> 0.00067) to hold the annual giving rate.
(hsim-event charity
  (nl         "?giver gives to charity")
  (kind [k _charity])
  (band      afternoon)
  (rng-stream behaviour)

  (roles
    ; High compassion gives to charity more.
    (role ?giver (template old_human)
                 (not (believes ?self {@self give ? ?}))
                 (chance (* 0.00067 (+ 0.4 (* 1.2 (attr ?self compassion)))))))

  (effects
    (give-alms ?giver)
    (log _charity ?giver)))
