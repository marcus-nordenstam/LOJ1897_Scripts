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

  (role @self (grown @self)
              (believes {@self home ?}))

  ; ?home binds on the when-spine (a self-role believes does not export its
  ; free vars to the event scope - the work_attendance shape). The COOK is the
  ; woman of the house - self-identified from @self's OWN gender belief (mental,
  ; no household-cook scan). Whichever adult woman fires first sets the hours;
  ; the (not supper_hour) gate then closes the window for the rest.
  (when (and (bind {@self home ?home})
             (not (believes {?home supper_hour ?}))
             (believes {@self gender [k female]})))

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

  (role @self (any_human @self)
              (believes {@self home ?}))
  ; The woman of the house, role-cast from the asker's OWN kinship beliefs: a
  ; female mother / parent / spouse (a child asks their mother; a husband his
  ; wife). Same {@self <kin> ?cand} cacheable shape covet uses. The woman
  ; herself (no female parent/spouse at home) casts nothing here - she already
  ; knows the hours, so she never needs to ask.
  (role ?cook (believes {@self mother|parent|spouse ?cook})
              (believes {?cook gender [k female]}))

  (when (and (bind {@self home ?home})
             (not (believes {?home supper_hour ?}))
             (>= (years-old @self) 3)))

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

  (when (and (is-entity ?asker)
             (bind {@self home ?home})
             (bind {?home breakfast_hour ?b})
             (bind {?home lunch_hour ?l})
             (bind {?home supper_hour ?s})))

  (cont-fire-effects
    (tell-to ?asker {?home breakfast_hour ?b}
                    {?home lunch_hour ?l}
                    {?home supper_hour ?s})
    ))

; ----------------------------------------------------------------------------
; plan_provisioning (npc-think) - the cook checks the larder and, if it is
; genuinely low, takes on the provisioning errand; the npc-act lanes
; (meals.hs provision_go_known / provision_search / provision_take) drain
; the goal. The check is DELIBERATE whereabouts work (take-stock-of,
; stocktake_macros.hs): her believed stock can be stale in both directions
; (phantom loaves the family ate unseen; loaves she forgot), so she walks
; the rooms she keeps food in and validates before deciding - checking the
; larder IS the act whose purpose is confirming / disproving those
; beliefs. She can only do that while physically home (window-start finds
; her there overnight). Gate order matters: the cheap believed-count
; pre-gate ("could it be low?") runs first, the (household-cook)
; resolution (an entity scan) only for possibly-low homes; the verified
; count decides.
; ----------------------------------------------------------------------------

; set_shop_schedule (npc-think) - the cook picks her personal grocery-run slot
; ONCE (mirrors set_mealtimes): a random weekday + start hour. This is the 2a
; staggering: with ~50 cooks scattered over 7 weekdays x an 8h window the town's
; grocer trips spread to ~1 shopper at a time instead of the whole town
; converging on the one shop the same day (the 256-contents stampede). A working
; cook whose slot falls in her shift simply provisions after it - the errand
; utility (55) yields to the work lane (80), so the slot is a floor, not a fence.
(npc-think set_shop_schedule
  (sim-window-think)
  (rng-stream behaviour)

  (role @self (grown @self)
              (believes {@self home ?}))

  (when (and (believes {@self gender [k female]})
             (not (believes {@self shop_weekday ?}))))

  (cont-fire-effects
    (begin-belief {@self shop_weekday (random-int 0 6)})
    (begin-belief {@self shop_hour (random-int 7 15)})))

; plan_provisioning (npc-think) - the cook takes on the weekly provisioning
; errand on HER scheduled slot; the npc-act lanes (meals.hs provision_go_known /
; provision_search / provision_take) drain the goal, buying a WEEK's stock at a
; time (top-up to larder_target) so the larder lasts to the next slot and the
; family never falls through to the per-NPC starving lanes. days-since-last
; provision is the once-a-week dedup (the worship.hs weekly-churchgoing pattern).
; Two fallbacks keep a straggler fed without re-synchronising the town: a
; catch-up (slot missed, shop any day) and an emergency (believed larder nearly
; bare) - both rare, and phased apart by each cook's own days-since clock.
(npc-think plan_provisioning
  (sim-window-think)

  (role @self (grown @self)
              (believes {@self home ?}))

  (when (and (bind {@self home ?home})
             (believes {@self gender [k female]})
             (bind {@self shop_weekday ?swd})
             (bind {@self shop_hour ?shr})
             (>= (days-since-last @self provision) 6)
             (or (and (= (now-weekday) ?swd) (>= (now-hour) ?shr))
                 (>= (days-since-last @self provision) 9)
                 (< (count-believed-located [k food] ?home) 3))))

  (cont-fire-effects (begin-goal {@self provision})))
