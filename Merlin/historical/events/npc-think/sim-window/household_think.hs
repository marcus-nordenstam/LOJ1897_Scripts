; ----------------------------------------------------------------------------
; household_day (npc-think). Records @self's day-at-home as an EPISODIC dwelling
; memory: an amenity-gated {@self rest <home>} by default, {@self dine <home>} if
; the home has a dining_room, {@self read_at <home>} if it has a study - so a
; manor yields a richer home-leisure record than a rowhouse (record-dwelling /
; pick_home_activity). The decay pass consolidates repeated identical episodes
; into a cumulative belief whose count is the frequency.
;
; A mental change (a dwelling-episode memory), so npc-think. Fired by the per-NPC
; window-start pass (monthly). Home CO-PRESENCE is no longer registered here - the
; physical rest lane (rest.hs) puts the NPC at home and the routine itinerary
; provides co-presence; this event only records the activity episode. Gated on
; having a home (the homeless do not dwell).
;
; NOTE: the dine episode is now owned by the SUPPER lane (npc-act/meals.hs,
; a real daily at-home act with table talk), so record-dwelling no longer
; picks dine - it records rest / read_at only. The read_at episode is still
; not reproduced by any other lane; a future home-leisure lane may subsume
; it. See the future_work "rest habit vs episodic collision" note re: the
; {@self rest <home>} record sharing the rest-habit shape.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think household_day
  (sim-window-think)
  (rng-stream behaviour)

  (role @self (any_human @self)
              (believes {@self home ?}))

  (cont-fire-effects
    (record-dwelling @self)
    ))

; ----------------------------------------------------------------------------
; set_mealtimes (npc-think) - the COOK decides the household mealtimes
; (tell-only comms plan, ruling 11). Fires for the ONE person
; (household-cook ?home) resolves (hired cook > woman of the house > adult
; daughter > head) when her OWN mind lacks the home's supper_hour - so it
; fires once per cook per home (and again only if the cook changes homes or
; the beliefs are somehow lost). The hours are HER decision (genesis, not
; communication): base 6/12/18 shifted by a per-cook offset, the whole day
; coherent. She then SAYS them aloud - at window start the household is home
; (asleep co-presence), so the residents adopt the facts from the say; any
; straggler self-heals through the ask-the-cook channel below.
; The missing-belief gate comes FIRST so the (household-cook) resolution
; (an entity scan) runs only while the mealtimes are actually unset.
; ----------------------------------------------------------------------------

(npc-think set_mealtimes
  (sim-window-think)
  (rng-stream behaviour)

  ; The COOK is the woman of the house - self-identified from @self's OWN gender
  ; belief (mental, no household-cook scan) - a CACHED self-gate filter. ?home is
  ; a CACHED role: home + no-supper-hour tested against the SAME candidate, and
  ; the role BINDS ?home for the effects. Whichever adult woman fires first sets
  ; the hours; the (not supper_hour) filter then empties for the whole household.
  (role @self (grown @self)
              (believes {@self gender [k female]}))
  (role ?home (believes {@self home ?home})
              (not (believes {?home supper_hour ?})))

  (cont-fire-effects
    ; The per-cook offset: -1 / 0 / +1 on the whole day (breakfast 5-7,
    ; lunch 11-13, supper 17-19; each window is 2h from the hour).
    (bind (if (chance 0.33) -1 (if (chance 0.5) 0 1)) ?o)
    (begin-belief {?home breakfast_hour (+ 6 ?o)})
    (begin-belief {?home lunch_hour (+ 12 ?o)})
    (begin-belief {?home supper_hour (+ 18 ?o)})
    ; Say the house's hours aloud - the household hears and adopts.
    (tell {?home breakfast_hour (+ 6 ?o)}
          {?home lunch_hour (+ 12 ?o)}
          {?home supper_hour (+ 18 ?o)})
    ))

; ----------------------------------------------------------------------------
; ask_mealtimes / answer_mealtimes - the ask-the-cook channel (ruling 12).
; A resident who does not know the house's supper hour ASKS the cook (a real
; question say - {@self SAY (qs {?home supper_hour _}) /aux cook}); the cook,
; gated on having HEARD such a question ((asked-me-about supper_hour) - the
; cheap per-mind gate comes first), answers with a directed tell of all three
; hours. tell-to's per-listener dedup makes re-answers harmless; the asked
; record fades on the normal recall curve. Semantic self-healing: mealtime
; knowledge can never be permanently lost while the cook lives.
; Both are SAYS (acts carried by perception), but they run at window start
; (the household's at-home hour) - npc-think placement keeps them beside
; set_mealtimes, whose decision they complete.
; ----------------------------------------------------------------------------

(npc-think ask_mealtimes
  (sim-window-think)
  (rng-stream behaviour)

  (role @self (any_human @self))
  ; The woman of the house, role-cast from the asker's OWN kinship beliefs: a
  ; female mother / parent / spouse (a child asks their mother; a husband his
  ; wife). Same {@self <kin> ?cand} cacheable shape covet uses. The woman
  ; herself (no female parent/spouse at home) casts nothing here - she already
  ; knows the hours, so she never needs to ask.
  (role ?cook (believes {@self mother|parent|spouse ?cook})
              (believes {?cook gender [k female]}))
  ; The unknown-hours gate as a CACHED role (binds ?home for the ask): empties
  ; the instant the supper hour is learned, closing the window for good.
  (role ?home (believes {@self home ?home})
              (not (believes {?home supper_hour ?})))

  (when (>= (years-old @self) 3))

  (cont-fire-effects
    (ask-to ?cook {?home supper_hour ?})
    ))

(npc-think answer_mealtimes
  (sim-window-think)
  (rng-stream behaviour)

  (role @self (grown @self)
              (believes {@self home ?}))

  ; The cheap per-mind gate first: (asked-me-about) walks only @self's own
  ; heard-SAY records and fails fast when nobody asked.
  (bind (asked-me-about supper_hour) ?asker)

  (role ?home (believes {@self home ?home})
              (believes {?home breakfast_hour ?b})   ; existence cached; the three
              (believes {?home lunch_hour ?l})       ; hours bind at fire for the
              (believes {?home supper_hour ?s}))     ; tell-to below
  (when (is-entity ?asker))

  (cont-fire-effects
    (tell-to ?asker {?home breakfast_hour ?b}
                    {?home lunch_hour ?l}
                    {?home supper_hour ?s})
    ))

; (plan_provisioning / set_shop_schedule are GONE: provisioning is the
; pressure-driven cook errand in npc-think/provisioning_think.hs - the kitchen
; larder count IS the schedule.)
