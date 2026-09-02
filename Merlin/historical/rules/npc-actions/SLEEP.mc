; ----------------------------------------------------------------------------
; rest (npc-action) - the sleep act of the FATIGUE / REST lane. The intra-day
; think rules (seek_rest / sleep / idle_go_home) live in npc-think/rest.hs;
; this file holds the durative sleep act promoted from the SLEEP desire.
; ----------------------------------------------------------------------------

; Sleep physics: recovery clears fatigue at 1/6 per hour (the engine's
; completion physiology), so the natural sleep length is fatigue x 6h. The
; floor is sleep inertia (even a barely-tired sleeper stays down a while).
(define-macro sleep-min-per-fatigue () 360)
(define-macro sleep-inertia-floor-min () 120)

; The sleep act, promoted from the SLEEP desire at home: the action computes
; its NATURAL duration from the sleeper's own physiology - no calendar, no
; schedule, no beliefs; sleeping is simulated, not reasoned. The actor wakes
; when the debt is slept off. A scream, an alarm or a physical attack should
; PREEMPT the running sleep (the engine preemption seam is future work); the
; old alarm-clock / obligation caps were schedule reasoning and are gone.
(npc-action {@self SLEEP}
  (duration (max (sleep-inertia-floor-min)
                 (* (sleep-min-per-fatigue) (attr @self fatigue))))
  (effects (set-outcome {@self SLEEP} /succ)))
