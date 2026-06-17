; ----------------------------------------------------------------------------
; Work activity lane (see Docs/hsim/hsim_social.md "Co-presence and activity
; lanes"). The twin of
; household.hse. Every alive employee records a day spent at work as the
; EPISODIC task {@self work <org>} ("working at the workplace") - minted
; begin+end at the visit date, because a day at work is a past event, not an
; ongoing state. The decay pass consolidates repeated days into a cumulative
; `work` belief whose count is the attendance frequency. The venue is the
; worker's employer org (recalled the same way the household lane recalls
; `home`). Co-workers minted in one firing share (org, date) - the substrate
; the L4 co-presence sweep reads.
;
; Standing-group lane: no (chance) gate - everyone with an employer works.
; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
; once a month (the twin of household_day, also emergent), same monthly cadence.
; The employer-belief role filter excludes the unemployed; the (alive ...) gate
; excludes the dead-but-unburied whose employer belief has not yet been cleared.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event work_day
  (nl         "?worker spends the day at work")
  (kind [k _work_day])
  (band      morning)
  (rng-stream behaviour)

  (roles
    (role ?worker (template any_human)
                  (believes ?self {@self employer ?})))

  (when (alive ?worker))

  (effects
    (record-work ?worker)
    (log _work_day ?worker)))
