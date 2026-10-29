; ----------------------------------------------------------------------------
; household-day-driver (think) - the home-leisure DRIVER. Proposes @self's
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


(include "../../macros/home-macros.mc")

(define-macro read-intellect-threshold () 0.5)

(driver household-day-driver
  (cooldown 1 m try-until-succ)

  (role @self {@self intellect ?intellect}
              {@self home ?home}
    (declare-utility idle)
    ; A bookish man - one keen on scholarship or letters, or of a high intellect - reads in
    ; the study when the house has one; anyone else rests.
    (preemptive-or
      (try
        (role @self {@self interest [k academic-field|literature]}
          (when (spatial ?home room [k study]))
          (effects (maintain-proposal {@self read-at ?home}))))
      (try
        (when (and (spatial ?home room [k study])
                   (>= ?intellect (read-intellect-threshold))))
        (effects (maintain-proposal {@self read-at ?home})))
      (try
        (effects (maintain-proposal {@self rest ?home}))))))

; The rest / read-at TASKS (the immediate-conclude outcome rungs) live in
; tasks/rest-task.mc and tasks/read-at-task.mc.

; ----------------------------------------------------------------------------
; set-mealtimes-driver - the woman of the house, holding the duty, fixes the household's meal
; hours while her own mind lacks the home's supper hour: she proposes the set-mealtimes task
; (tasks/set-mealtimes-task.mc), which says the hours aloud to the household and then holds them
; herself. Any straggler self-heals through the ask-the-cook channel below.
; ----------------------------------------------------------------------------


(driver set-mealtimes-driver
  (cooldown 1 m try-until-succ)

  ; The COOK is the woman of the house - self-identified from @self's OWN gender
  ; belief (mental, no household-cook scan) - a CACHED self-gate filter. ?home is
  ; a CACHED role: home + no-supper-hour tested against the SAME candidate, and
  ; the role BINDS ?home for the effects. Whichever adult woman fires first sets
  ; the hours; the (not supper-hour) filter then empties for the whole household.
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
              {@self gender [k female]}
    (role ?household [k household] {@self duty-to ?household set-mealtimes}
      (role ?home {@self home ?home}
        (when -{?home supper-hour ?})
        (declare-utility want)
        (effects (maintain-proposal {@self set-mealtimes ?household}))))))

; (plan_provisioning / set_shop_schedule are GONE: provisioning is the
; pressure-driven cook errand in thinks/provisioning_think.mc - the kitchen
; larder count IS the schedule.)
