; ----------------------------------------------------------------------------
; bonded_incident_outdo (PR-A-7 V2, 2026-05-28, multiplicative).
;
; Organic source of rivalrous_act anchors. Replaces test_seed_rivalry's
; chance-primary scaffold; the latter retires under PR-A-10 once
; substrate-rooted coverage is broad enough.
;
; The plan's outcome row:
;   outdo  | assertiveness x narcissism
;          | same-field competition x aggression-situation
;          | LIFE_AIM_ALIGN +wealth, +power
;
; V2 gating: multiplicative-chance over assertiveness x narcissism
; x normalized-aggression (situation aggression / 100). A modal NPC
; at (0.5, 0.5, 50) hits base x 0.125; a sharp competitor at (0.7,
; 0.65, 70) hits base x 0.32 - ~2.5x firing rate.
;
; V3 (PR-skill-life S8): same-field competition is now wired. The victim
; chance DOUBLES when actor and victim are skilled in overlapping domains
; (same-domain-skilled, the S2 predicate - live now that S4/S6 mint skilled_in):
; professional rivals outdo each other far more than strangers-in-trade.
;
; categorize fires:
;   victim (pov=patient):
;     - rivalrous_act -> envy + contempt + rivalry_pressure pressure
;   actor (pov=actor):
;     - (no reaction row authored - winners do not appraise their own
;       positional success as a wrong)
;
; Schedule: monthly. Per-pair 90-day cooldown via recent_incident.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event bonded_incident_outdo
  (nl       "?actor outdoes ?victim")
  (kind     _bonded_incident_outdo)
  (schedule (monthly))
  (band      afternoon)
  (rng-stream incidents)

  (roles
    (role ?actor  (template any_human)
                  (chance (* 0.08
                             (attr ?actor assertiveness)
                             (attr ?actor narcissism)
                             (situation ?actor aggression))))
    (role ?victim (template any_human)
                  (not (= ?victim ?actor))
                  (personally-knows ?actor ?victim)
                  (not (has-recent-incident-marker ?actor ?victim))
                  (chance (* 0.10 (+ 1.0 (same-domain-skilled ?actor ?victim))))))

  (effects
    (incident-anchor ?actor outdo ?victim)
    (log _bonded_incident_outdo ?actor)))
