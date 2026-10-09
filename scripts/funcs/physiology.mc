; ----------------------------------------------------------------------------
; run_physiology (define-func) - the bodily-drive advance, authored as content.
;
; Invoked by the engine (call_hs_func, cached index) at EACH act completion, on
; the completing actor, with ?duration = the act's elapsed minutes and ?recovers = 1
; iff it was a SLEEP act (else 0). A plain callable func - no act-belief, no
; deliberation; C++ only supplies the two per-completion scalars.
;
; The drives (the ONE seam where the body advances):
;  - ADRENALINE decays toward 0 over ~1h of non-fight acts (the fight / flee /
;    scream acts pump it to 1 content-side). It MASKS the felt drives: the raw
;    fatigue / hunger DEBTS keep accruing, but sleepiness / appetite = debt*mask,
;    so a combatant reads calm until the surge fades - then the debt lands at
;    once (the post-fight crash).
;  - FATIGUE: a SLEEP act recovers it, any other act accrues waking fatigue.
;    Sleepiness = mask * (fatigue + the body clock's pressure) drives the sleep pull.
;  - HUNGER: every act accrues it, sleep included (you wake hungry). Meal acts
;    reduce it content-side. Appetite = mask * hunger, held down through his night,
;    gates the meal aspect.
;
; ATTRS, the BANDS the mind knows them by, and the one think alarm a waking books for his
; bedtime. The drives are imperceptible scalars: the mind holds only {@self alertness <band>}
; and {@self satiety <band>}, minted here with the band dead-band, so a belief is written only
; when a drive crosses a threshold.
; ----------------------------------------------------------------------------

(include "../macros/physiology-macros.mc")

; The hour of the instant ?t on @self's own clock, 0 .. 24.
(define-func circadian-hour (?t)
  (modulo (- (+ /float (hour ?t) (/ /float (minute ?t) (minutes_per_hour))) (attr @self chronotype))
          (hours_per_day)))

; The body clock's pressure toward sleep at the instant ?t: +amp at night, -amp by day,
; ramping across his midnight and his morning hour.
(define-func circadian-pressure (?t)
  (circadian-hour ?t): ?u
  (cond (case (< ?u (circadian_ramp_hours))
              (* (circadian_amp) (/ ?u (circadian_ramp_hours))))
        (case (< ?u (- (circadian_morning_hour) (circadian_ramp_hours)))
              (circadian_amp))
        (case (< ?u (+ (circadian_morning_hour) (circadian_ramp_hours)))
              (* (circadian_amp) (/ (- (circadian_morning_hour) ?u) (circadian_ramp_hours))))
        (case (< ?u (- (hours_per_day) (circadian_ramp_hours)))
              (- 0.0 (circadian_amp)))
        (else (* (circadian_amp) (/ (- ?u (hours_per_day)) (circadian_ramp_hours))))))

; On waking, book the think at which the day's fatigue and his body clock will carry him into
; the tired band, so he goes to bed within a step of it rather than at the next heartbeat.
(define-func book-bedtime-alarm (?fatigue ?mask)
  (bind 0.0 ?k)
  (repeat (body_clock_search_steps)
    (bind (+ ?k 1.0) ?k)
    (bind (* ?k (body_clock_step_min)) ?m)
    (bind (+ (time seconds) (seconds ?m min)) ?at)
    (bind (+ ?fatigue (* (/ ?m (minutes_per_hour)) (fatigue_accrue_per_hour))) ?f)
    (if (>= (* ?mask (+ ?f (circadian-pressure ?at))) (+ (tired_min) (band-dead-band)))
        (then (set-think-alarm ?at) (break)))))

; How long a sleep begun now lasts: until the debt left and the body clock together no longer
; press, and never shorter than the inertia floor.
(define-func sleep-duration-min ()
  (attr @self fatigue): ?f
  (bind 0.0 ?k)
  (bind (* (body_clock_search_steps) (body_clock_step_min)) ?min)
  (repeat (body_clock_search_steps)
    (bind (+ ?k 1.0) ?k)
    (bind (* ?k (body_clock_step_min)) ?m)
    (bind (max 0.0 (- ?f (* (/ ?m (minutes_per_hour)) (fatigue_recover_per_hour)))) ?left)
    (if (and (>= ?m (sleep_inertia_min))
             (<= (+ ?left (circadian-pressure (+ (time seconds) (seconds ?m min)))) 0.0))
        (then (bind ?m ?min) (break))))
  ?min)

(define-func emit-body-bands (?sleepiness ?appetite)
  (mint-band {@self alertness} ?sleepiness [k sleepy] (sleepy_min) [k tired] (tired_min) [k alert] -1)
  (mint-band {@self satiety} ?appetite [k famished] (famished_min) [k hungry] (hungry_min) [k sated] -1))

(define-func /physiology run_physiology (?duration ?act)
  ; WHICH ACT RECOVERS THE BODY IS CONTENT, so it is decided here. The engine used to
  ; answer this by comparing the concluded act against a hardcoded SLEEP and handing
  ; down a 0/1; it now hands down the act LABEL and asks nothing.
  (cond (case (eq ?act SLEEP) 1.0)
        (else                 0.0)): ?recovers
  (/ ?duration (minutes_per_hour)): ?hours
  (circadian-pressure (time seconds)): ?clock

  (clamp (- (attr @self adrenaline) (* ?hours (adrenaline_decay_per_hour)))
         0.0 (adrenaline_max)): ?adren
  (- 1.0 ?adren): ?mask

  (- (* (* ?hours (fatigue_accrue_per_hour)) (- 1.0 ?recovers))
     (* (* ?hours (fatigue_recover_per_hour)) ?recovers)): ?df
  (clamp (+ (attr @self fatigue) ?df) 0.0 (fatigue_max)): ?fatigue
  (clamp (* ?mask (+ ?fatigue ?clock)) 0.0 (fatigue_max)): ?sleepiness

  (clamp (+ (attr @self hunger) (* ?hours (hunger_accrue_per_hour)))
         0.0 (hunger_max)): ?hunger
  (clamp (* ?mask (- ?hunger (max 0.0 ?clock))) 0.0 (hunger_max)): ?appetite

  (set-attr @self adrenaline ?adren)

  (set-attr @self fatigue ?fatigue)
  (set-attr @self sleepiness ?sleepiness)

  (set-attr @self hunger ?hunger)
  (set-attr @self appetite ?appetite)
  (emit-body-bands ?sleepiness ?appetite)
  (if (eq ?act SLEEP) (then (book-bedtime-alarm ?fatigue ?mask))))

; True when ?job's shift on weekday ?wd runs past midnight.
(define-func shift-wraps-midnight (?job ?wd)
  (table-match weekday_hours_label weekday ?wd label ?swm-label)
  (if (none {?job ?swm-label ?})
      (then @false)
      (else (gt (any {?job ?swm-label ?}).target (any {?job ?swm-label ?}).auxiliary))))

; True when @self lives by night: his shift last night or tonight runs past midnight.
(define-func lives-by-night ()
  (time weekday): ?lbn-today
  (if (= ?lbn-today 1) (then 7) (else (- ?lbn-today 1))): ?lbn-yesterday
  (if (none {@self job ?})
      (then @false)
      (else (or (shift-wraps-midnight (any {@self job ?}).target ?lbn-today)
                (shift-wraps-midnight (any {@self job ?}).target ?lbn-yesterday)))))

; A jump window opens at the town's waking hour after a month nobody lived: the body is the one a
; night's sleep leaves - rested, calm, as hungry as the night's fast made him. A man who lives by
; night comes to it spent from his shift instead, with the debt that sleeps him till his waking hour.
(define-func /window-start morning_body ()
  (* (- (night_waking_hour) (+ /float (hour (time seconds)) (/ /float (minute (time seconds)) (minutes_per_hour))))
     (minutes_per_hour)): ?until-waking-min
  (if (lives-by-night)
      (then (- (* (/ ?until-waking-min (minutes_per_hour)) (fatigue_recover_per_hour))
               (circadian-pressure (+ (time seconds) (seconds ?until-waking-min min)))))
      (else 0.0)): ?fatigue
  (circadian-pressure (time seconds)): ?clock
  (clamp (+ ?fatigue ?clock) 0.0 (fatigue_max)): ?sleepiness
  (* (overnight_fast_hours) (hunger_accrue_per_hour)): ?hunger
  (clamp (- ?hunger (max 0.0 ?clock)) 0.0 (hunger_max)): ?appetite
  (set-attr @self adrenaline 0.0)
  (set-attr @self fatigue ?fatigue)
  (set-attr @self sleepiness ?sleepiness)
  (set-attr @self hunger ?hunger)
  (set-attr @self appetite ?appetite)
  (emit-body-bands ?sleepiness ?appetite))
