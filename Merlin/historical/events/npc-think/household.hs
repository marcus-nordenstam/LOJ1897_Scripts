; ----------------------------------------------------------------------------
; household_day (npc-think). Records @self's day-at-home as an EPISODIC dwelling
; memory: an amenity-gated {@self rest <home>} by default, {@self dine <home>} if
; the home has a dining_room, {@self read_at <home>} if it has a study - so a
; manor yields a richer home-leisure record than a tenement (record-dwelling /
; pick_home_activity). The decay pass consolidates repeated identical episodes
; into a cumulative belief whose count is the frequency.
;
; A mental change (a dwelling-episode memory), so npc-think. Fired by the per-NPC
; window-start pass (monthly). Home CO-PRESENCE is no longer registered here - the
; physical rest lane (rest.hs) puts the NPC at home and the routine itinerary
; provides co-presence; this event only records the activity episode. Gated on
; having a home (the homeless do not dwell).
;
; NOTE: the home-activity episodes (dine / read_at) this records are not yet
; reproduced by any other lane (the rest lane only mints sleep); a future
; home-leisure lane may subsume this. See the future_work "rest habit vs episodic
; collision" note re: the {@self rest <home>} record sharing the rest-habit shape.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event household_day
  (sim-window-start)
  (nl         "@self spends the day at home")
  (rng-stream behaviour)

  (roles
    (role @self (template any_human)
                (believes @self {@self home ?})))

  (effects
    (record-dwelling @self)
    (log _household_day @self)))
