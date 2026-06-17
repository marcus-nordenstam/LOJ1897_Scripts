; ----------------------------------------------------------------------------
; Household activity lane (see Docs/hsim/hsim_social.md "Co-presence and
; activity lanes"). Every alive
; resident records a day spent at home as an EPISODIC memory - minted begin+end
; at the visit date, because a day at home is a past event, not an ongoing
; state. The activity is SPECIFIC and amenity-gated: {@self rest <home>} by
; default, {@self dine <home>} if the home has a dining_room, {@self read_at
; <home>} if it has a study (every house but the dense terrace/tenement) - so a
; manor yields a richer leisure menu than a tenement (record-dwelling /
; pick_home_activity in hse_engine.cc). The decay
; pass consolidates repeated identical episodes into a cumulative belief whose
; count is the frequency. The venue is the dweller's own home (no venue choice).
; Co-residents minted in one firing share (home, date) - the substrate the L4
; co-presence sweep + L6 domestic incidents read.
;
; Standing-group lane: no (chance) gate - everyone with a home dwells. Fires
; once per month on the active-day bag (L0). The home-belief role filter
; excludes the homeless; the (alive ...) gate excludes the dead-but-unburied
; whose home belief has not yet been cleared.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event household_day
  (nl         "?dweller spends the day at home")
  (kind [k _household_day])
  ; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
  ; (monthly). The home dwelling-episode is true (the NPC is home); home
  ; co-presence is no longer registered here (the routine itinerary does it).
  (band      morning)
  (rng-stream behaviour)

  (roles
    (role ?dweller (template any_human)
                   (believes ?self {@self home ?})))

  (when (alive ?dweller))

  (effects
    (record-dwelling ?dweller)
    (log _household_day ?dweller)))
