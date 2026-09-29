; ----------------------------------------------------------------------------
; physiology_macros.mc - the tunable rates + band thresholds the physiology
; action (physiology-action.mc) advances each act completion. All content: the
; engine only triggers the action and supplies the elapsed minutes + a recovers
; flag; the model itself lives here.
; ----------------------------------------------------------------------------

; ADRENALINE: a full surge fades over ~1h of non-fight acts (decay per hour).
(define-macro adrenaline_decay_per_hour () 1.0)
(define-macro adrenaline_max () 1.0)

; FATIGUE: a SLEEP act recovers it (6h clears a full 1.0); any other act accrues
; waking fatigue (~1.0 over a 16h day).
(define-macro fatigue_recover_per_hour () (/ 1.0 6.0))
(define-macro fatigue_accrue_per_hour () (/ 1.0 16.0))
(define-macro fatigue_max () 2.0)

; THE BODY CLOCK: a pressure toward sleep in fatigue units, read on the PERSONAL clock (the
; world hour minus the man's chronotype). It holds +amp through the night and -amp through the
; day, ramping across midnight and across the morning hour, so a late night or a lie-in pulls
; the next bedtime and waking back toward the clock instead of carrying them forward. The same
; night holds his appetite down, so each man breakfasts on his own morning.
(define-macro minutes_per_hour () 60.0)
(define-macro hours_per_day () 24.0)
(define-macro circadian_amp () 0.25)
(define-macro circadian_ramp_hours () 1.0)
(define-macro circadian_morning_hour () 6.0)
(define-macro chronotype_sigma_hours () 0.5)
(define-macro chronotype_max_hours () 1.0)

; SLEEP: a man goes to bed once his alertness band turns tired, and urgently once it turns
; sleepy; an unslept debt turns it in the day, and that is a nap. A sleep ends once the debt
; left and the body clock together no longer press, never before the inertia floor.
(define-macro sleep_inertia_min () 120.0)
(define-macro body_clock_step_min () 10.0)
(define-macro body_clock_search_steps () 144.0)

; HUNGER: every act accrues it, sleep included - you wake hungry. Meal acts
; reduce it content-side (set-attr @self hunger ...).
(define-macro hunger_accrue_per_hour () (/ 1.0 16.0))
(define-macro hunger_max () 2.0)

; THE BANDS the mind knows its body by - run_physiology mints them from the ADRENALINE-MASKED
; drives, and no rule reads the drives themselves. Alertness over sleepiness: < tired_min alert,
; < sleepy_min tired, else sleepy. Satiety over appetite: < hungry_min sated, < famished_min
; hungry, else famished.
(define-macro sleepy_min () 1.0)
(define-macro tired_min () 0.5)
(define-macro famished_min () 1.1)
(define-macro hungry_min () 0.5)
