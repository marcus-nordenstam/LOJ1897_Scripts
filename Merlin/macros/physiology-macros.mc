; ----------------------------------------------------------------------------
; physiology_macros.hs - the tunable rates + band thresholds the physiology
; action (physiology-action.hs) advances each act completion. All content: the
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

; HUNGER: every act accrues it, sleep included - you wake hungry. Meal acts
; reduce it content-side (set-attr @self hunger ...).
(define-macro hunger_accrue_per_hour () (/ 1.0 16.0))
(define-macro hunger_max () 2.0)

; Band thresholds over the ADRENALINE-MASKED drive (STRONGEST-first). Alertness
; over masked fatigue (sleepiness): < tired_min alert, < sleepy_min tired, else
; sleepy. Satiety over masked hunger (appetite): < hungry_min sated, <
; famished_min hungry, else famished (the starvation tail knee sits above).
(define-macro sleepy_min () 1.0)
(define-macro tired_min () 0.5)
(define-macro famished_min () 1.1)
(define-macro hungry_min () 0.5)
