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
; ATTRS, plus the one think alarm a waking books for his bedtime. The engine's
; update_physiology calls this and then mirrors the actor's attrs into self-beliefs, so
; every drive this func moves arrives on the belief plane by the one route every other
; attr takes. A belief minted here would be a second, divergent account of the same number.
; ----------------------------------------------------------------------------

(include "../macros/physiology-macros.mc")

; The hour of the instant ?t on @self's own clock, 0 .. 24.
(define-func circadian-hour (?t)
  (- (+ /float (hour ?t) (/ /float (minute ?t) (minutes_per_hour))) (attr @self chronotype)): ?u
  (cond (case (< ?u 0.0) (+ ?u (hours_per_day)))
        (case (>= ?u (hours_per_day)) (- ?u (hours_per_day)))
        (else ?u)))

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

; On waking, book the think at which the day's fatigue and his body clock will reach the sleep
; gate, so he goes to bed within a step of it rather than at the next heartbeat.
(define-func book-bedtime-alarm (?fatigue ?mask)
  (bind 0.0 ?k)
  (repeat (body_clock_search_steps)
    (bind (+ ?k 1.0) ?k)
    (bind (* ?k (body_clock_step_min)) ?m)
    (bind (+ (time seconds) (seconds ?m min)) ?at)
    (bind (+ ?fatigue (* (/ ?m (minutes_per_hour)) (fatigue_accrue_per_hour))) ?f)
    (if (>= (* ?mask (+ ?f (circadian-pressure ?at))) (sleep_gate))
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
  (if (eq ?act SLEEP) (then (book-bedtime-alarm ?fatigue ?mask))))

; A jump window opens at midnight after a month nobody lived: the body is the one an ordinary
; waking day leaves - sleepy enough on his own clock that bed outbids everything, calm, fed at
; supper.
(define-func /window-start midnight_body ()
  (- (sleepy_min) (circadian-pressure (time seconds))): ?fatigue
  (set-attr @self adrenaline 0.0)
  (set-attr @self fatigue ?fatigue)
  (set-attr @self sleepiness (sleepy_min))
  (set-attr @self hunger 0.0)
  (set-attr @self appetite 0.0))
