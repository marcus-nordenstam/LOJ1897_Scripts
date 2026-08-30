; ----------------------------------------------------------------------------
; household_day (npc-think) - the home-leisure DRIVER. Proposes @self's
; day-at-home as a real task through the action pipeline: an amenity-gated
; {@self rest <home>} by default, {@self read_at <home>} if the home is known
; to have a study (scholarly temperaments favour it - the read weight scales
; with intellect) - so a manor yields a richer home-leisure record than a
; rowhouse. The room gate reads @self's OWN {?home room [k study]} beliefs
; (seeded at home acquisition by the rooms pre-teach) - no world search.
; home_leisure_done concludes the promoted task on the spot, so the ended task
; belief IS the episodic memory; the decay pass consolidates repeated
; identical episodes into a cumulative belief whose count is the frequency.
;
; Monthly per homed NPC (the homeless do not dwell), at a LOW utility: leisure
; fills an idle day and never displaces real work - a busy month simply
; records no home-leisure episode. Home CO-PRESENCE is not registered here -
; the physical rest lane (rest.hs) puts the NPC at home and the routine
; itinerary provides co-presence.
;
; NOTE: the dine episode is owned by the SUPPER lane (npc-act/meals.hs,
; a real daily at-home act with table talk), so the pick here is rest /
; read_at only.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(define-macro rest-weight ()                 100)
(define-macro read-weight-base ()            40)
(define-macro read-weight-intellect-scale () 120)

(npc-think household_day
  (cooldown 1 m)
  (rng-stream behaviour)

  (role @self {@self home ?home})
  (utility idle)

  (effects
    (if (spatial ?home room [k interior_space study])
              (then (+ (read-weight-base)
                       (* (read-weight-intellect-scale) (attr @self intellect))))
              (else 0)): ?read_w
    (if (chance (/ ?read_w (+ (rest-weight) ?read_w)))
        (then (begin-proposal {@self read_at ?home}))
        (else (begin-proposal {@self rest ?home})))))

; The rest / read_at TASKS (the immediate-conclude outcome rungs) live in
; npc-tasks/rest-task.hs and npc-tasks/read_at-task.hs.

; ----------------------------------------------------------------------------
; set_mealtimes (npc-think) - the COOK decides the household mealtimes
; (tell-only comms plan, ruling 11). Fires for the ONE person
; (household-cook ?home) resolves (hired cook > woman of the house > adult
; daughter > head) when her OWN mind lacks the home's supper_hour - so it
; fires once per cook per home (and again only if the cook changes homes or
; the beliefs are somehow lost). The hours are HER decision (genesis, not
; communication): base 6/12/18 shifted by a per-cook offset, the whole day
; coherent. She then SAYS them aloud - the household is home
; (asleep co-presence), so the residents adopt the facts from the say; any
; straggler self-heals through the ask-the-cook channel below.
; The missing-belief gate comes FIRST so the (household-cook) resolution
; (an entity scan) runs only while the mealtimes are actually unset.
; ----------------------------------------------------------------------------

(npc-think set_mealtimes
  (cooldown 1 m)
  (rng-stream behaviour)

  ; The COOK is the woman of the house - self-identified from @self's OWN gender
  ; belief (mental, no household-cook scan) - a CACHED self-gate filter. ?home is
  ; a CACHED role: home + no-supper-hour tested against the SAME candidate, and
  ; the role BINDS ?home for the effects. Whichever adult woman fires first sets
  ; the hours; the (not supper_hour) filter then empties for the whole household.
  (role @self (grown @self)
              {@self gender [k female]})
  (role ?home {@self home ?home}
              (not {?home supper_hour ?}))

  (effects
    ; The per-cook offset: -1 / 0 / +1 on the whole day (breakfast 5-7,
    ; lunch 11-13, supper 17-19; each window is 2h from the hour).
    (if (chance 0.33) (then -1) (else (if (chance 0.5) (then 0) (else 1)))): ?o
    (begin-belief {?home breakfast_hour (+ 6 ?o)})
    (begin-belief {?home lunch_hour (+ 12 ?o)})
    (begin-belief {?home supper_hour (+ 18 ?o)})
    ; Say the house's hours aloud - the household hears and adopts.
    (tell (utterable-msg {?home breakfast_hour (+ 6 ?o)}
                         {?home lunch_hour (+ 12 ?o)}
                         {?home supper_hour (+ 18 ?o)}))
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
; Both are SAYS (acts carried by perception), but they run at the household's
; at-home hour - npc-think placement keeps them beside
; set_mealtimes, whose decision they complete.
; ----------------------------------------------------------------------------

(npc-think ask_mealtimes
  (cooldown 1 m)
  (rng-stream behaviour)

  (role @self )
  ; The woman of the house, role-cast from the asker's OWN kinship beliefs: a
  ; female mother / parent / spouse (a child asks their mother; a husband his
  ; wife). Same {@self <kin> ?cand} cacheable shape covet uses. The woman
  ; herself (no female parent/spouse at home) casts nothing here - she already
  ; knows the hours, so she never needs to ask.
  (role ?cook {@self mother|parent|spouse ?cook}
              {?cook gender [k female]})
  ; The unknown-hours gate as a CACHED role (binds ?home for the ask): empties
  ; the instant the supper hour is learned, closing the window for good.
  (role ?home {@self home ?home}
              (not {?home supper_hour ?}))

  (when (>= (years-old @self) 3))

  ; Learning the house's hours beats settling into a leisure day.
  (utility idle (above rest))

  (effects
    (utterable-qs {?home supper_hour ?}): ?qs
    (maintain-proposal {@self SAY ?qs ?cook})))

(npc-think answer_mealtimes
  (cooldown 1 m)
  (rng-stream behaviour)

  (role @self (grown @self)
              {@self home ?home}
              {?home breakfast_hour ?b}   ; existence cached; the three
              {?home lunch_hour ?l}       ; hours bind at fire for the
              {?home supper_hour ?s})

  ; Someone asked @self about supper_hour: a heard qs about supper_hour with
  ; @self as the audience. Binds ?asker (the speaker, not @self).
  (role ?asker (any_human ?asker)
               {?asker SAY (qs {? supper_hour ?}) @self /past})

  (effects
    (tell-to ?asker (utterable-msg {?home breakfast_hour ?b}
                                   {?home lunch_hour ?l}
                                   {?home supper_hour ?s}))
    ))

; (plan_provisioning / set_shop_schedule are GONE: provisioning is the
; pressure-driven cook errand in npc-think/provisioning_think.hs - the kitchen
; larder count IS the schedule.)
