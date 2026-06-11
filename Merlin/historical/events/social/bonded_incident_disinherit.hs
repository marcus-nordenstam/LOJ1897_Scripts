; ----------------------------------------------------------------------------
; bonded_incident_disinherit (PR-A-7 V2, 2026-05-28, multiplicative).
;
; Organic source of abandonment_act + wrong_act anchors. Replaces
; test_seed_disinheritance's chance-primary scaffold; the latter
; retires under PR-A-10 once substrate-rooted coverage is broad enough.
;
; The plan's outcome row:
;   disinherit / desert / fire
;       | low compassion x narcissism
;       | requires authority-over x value-rift
;       | LIFE_AIM_ALIGN +legacy, +respectability
;
; V2 gating: multiplicative-chance over (1 - compassion) x narcissism
; on the actor side; the family-disinheritance variant gates on
; actor-is-parent-of-victim (the authority-over predicate for the
; family case). value-rift becomes an AMPLIFIER on the victim side
; (additive 0.2 floor, so the rift is a 5x amplifier when fully
; present rather than a hard gate that excludes the entire population
; today - no event mints value beliefs yet, so modal rift = 0).
;
; categorize fires:
;   victim (pov=patient):
;     - abandonment_act -> grief + distress + attachment_loss
;                          pressure + status_loss pressure +
;                          end-bonds (love / friend)
;     - wrong_act -> anger + injustice pressure + humiliation
;   actor (pov=actor):
;     - abandonment_act -> guilt + moral_violation pressure
;     - wrong_act -> guilt + fear + moral_violation +
;                    exposure_risk pressure
;
; Schedule: annually september.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event bonded_incident_disinherit
  (nl       "?actor disinherits ?victim")
  (kind     _bonded_incident_disinherit)
  (schedule (annually september))
  (band      afternoon)
  (rng-stream incidents)

  (roles
    (role ?actor  (template any_human)
                  (chance (* 0.30
                             (- 1.0 (attr ?actor compassion))
                             (attr ?actor narcissism))))
    (role ?victim (template any_human)
                  (not (= ?victim ?actor))
                  (believes ?actor {@self child ?victim})
                  (not (has-recent-incident-marker ?actor ?victim))
                  (chance (* 0.80
                             (+ 0.2 (value-rift ?actor ?victim))))))

  (effects
    (incident-anchor ?actor disinherit ?victim)
    (log _bonded_incident_disinherit ?actor)))
