; ----------------------------------------------------------------------------
; household-day (think) - the home-leisure DRIVER. Proposes @self's
; day-at-home as a real task through the action pipeline: an amenity-gated
; {@self rest <home>} by default, {@self read-at <home>} if the home is known
; to have a study (scholarly temperaments favour it - the read weight scales
; with intellect) - so a manor yields a richer home-leisure record than a
; rowhouse. The room gate reads @self's OWN spatial index of the home, (spatial ?home
; room [k study]) (seeded at home acquisition by the rooms pre-teach) - no world search.
; home_leisure_done concludes the promoted task on the spot, so the ended task
; belief IS the episodic memory; the decay pass consolidates repeated
; identical episodes into a cumulative belief whose count is the frequency.
;
; Monthly per homed NPC (the homeless do not dwell), at a LOW utility: leisure
; fills an idle day and never displaces real work - a busy month simply
; records no home-leisure episode. Home CO-PRESENCE is not registered here -
; the physical rest aspect (rest.mc) puts the NPC at home and the routine
; itinerary provides co-presence.
;
; NOTE: the dine episode is owned by the SUPPER aspect (npc-act/meals.mc,
; a real daily at-home act with table talk), so the pick here is rest /
; read-at only.
; ----------------------------------------------------------------------------


(define-macro read-intellect-threshold () 0.5)
(define-macro household-breakfast-hour () 6)
(define-macro household-lunch-hour ()     12)
(define-macro household-supper-hour ()    18)

(think household-day
  (cooldown 1 m try-until-succ)

  (role @self {@self intellect ?intellect}
              {@self home ?home}
    (declare-utility idle)

    (effects
      (bind 0 ?bookish)
      (for-each ?interest (every {@self interest ?})
        (if (or (is-a ?interest.target [k academic-field]) (is-a ?interest.target [k literature]))
            (then (bind 1 ?bookish))))
      (if (and (spatial ?home room [k study])
               (or (= ?bookish 1)
                   (>= ?intellect (read-intellect-threshold))))
          (then (maintain-proposal {@self read-at ?home}))
          (else (maintain-proposal {@self rest ?home}))))))

; The rest / read-at TASKS (the immediate-conclude outcome rungs) live in
; tasks/rest-task.mc and tasks/read-at-task.mc.

; ----------------------------------------------------------------------------
; set-mealtimes (think) - the COOK decides the household mealtimes
; (tell-only comms plan, ruling 11). Fires for the ONE person
; (household-cook ?home) resolves (hired cook > woman of the house > adult
; daughter > head) when her OWN mind lacks the home's supper-hour - so it
; fires once per cook per home (and again only if the cook changes homes or
; the beliefs are somehow lost). The hours are HER decision (genesis, not
; communication): the household's breakfast / lunch / supper hours. She then SAYS them aloud - the household is home
; (asleep co-presence), so the residents adopt the facts from the say; any
; straggler self-heals through the ask-the-cook channel below.
; The missing-belief gate comes FIRST so the (household-cook) resolution
; (an entity scan) runs only while the mealtimes are actually unset.
; ----------------------------------------------------------------------------

(think set-mealtimes
  (cooldown 1 m try-until-succ)

  ; The COOK is the woman of the house - self-identified from @self's OWN gender
  ; belief (mental, no household-cook scan) - a CACHED self-gate filter. ?home is
  ; a CACHED role: home + no-supper-hour tested against the SAME candidate, and
  ; the role BINDS ?home for the effects. Whichever adult woman fires first sets
  ; the hours; the (not supper-hour) filter then empties for the whole household.
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
              {@self gender [k female]}
    (role ?home {@self home ?home}
      ; Latched: the hours this fire sets would fell a live residual and withdraw the tell that
      ; announces them; latched at onset, the activation holds through the announcement.
      (when (latch-eval -{?home supper-hour ?}))

      (declare-utility want)

      (effects
        (begin-belief {?home breakfast-hour (household-breakfast-hour)})
        (begin-belief {?home lunch-hour (household-lunch-hour)})
        (begin-belief {?home supper-hour (household-supper-hour)})
        ; Say the house's hours aloud - the household hears and adopts.
        (maintain-proposal {@self tell (utterable-msg [] {?home breakfast-hour (household-breakfast-hour)}
                                                   {?home lunch-hour (household-lunch-hour)}
                                                   {?home supper-hour (household-supper-hour)}) _})
        ))))

; ----------------------------------------------------------------------------
; ask-mealtimes - the ask-the-cook channel (ruling 12). A resident who does not know
; the house's supper hour ASKS the cook: he hails her (tasks/hail-task.mc) and, once she has
; taken him up, holds a conversation whose agenda is the question. The cook answers it as
; anyone answers a question put to him in conversation (tasks/converse-task.mc). Semantic self-healing: mealtime knowledge can never be
; permanently lost while the cook lives. Think placement keeps it beside
; set-mealtimes, whose decision it completes.
; ----------------------------------------------------------------------------

(driver ask-mealtimes
  (cooldown 1 m try-until-succ)
  (rng-stream behaviour)

  (role @self {@self age ?age}
    ; The woman of the house, role-cast from the asker's OWN kinship beliefs: a
    ; female mother / parent / spouse (a child asks their mother; a husband his
    ; wife). Same {@self <kin> ?cand} cacheable shape covet uses. The woman
    ; herself (no female parent/spouse at home) casts nothing here - she already
    ; knows the hours, so she never needs to ask.
    (role ?cook {@self mother|parent|spouse ?cook}
                {?cook gender [k female]}
      ; The unknown-hours gate as a CACHED role (binds ?home for the ask): empties
      ; the instant the supper hour is learned, closing the window for good.
      (role ?home {@self home ?home}
                  -{?home supper-hour ?}

        (when (>= ?age 3))

        ; Learning the house's hours beats settling into a leisure day.
        (declare-utility idle (above rest))

        (stable-or
          (try
            (when (not (conversing-with ?cook @self)))
            (effects (maintain-proposal {@self hail ?cook})))
          (try
            (when (conversing-with @self ?cook) (conversing-with ?cook @self))
            (effects
              (utterable-qs [] {?home supper-hour ?}): ?qs
              (maintain-proposal {@self converse ?cook ?qs}))))))))

; (plan_provisioning / set_shop_schedule are GONE: provisioning is the
; pressure-driven cook errand in thinks/provisioning_think.mc - the kitchen
; larder count IS the schedule.)
