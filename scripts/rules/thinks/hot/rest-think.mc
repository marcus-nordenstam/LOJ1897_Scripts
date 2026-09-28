; ----------------------------------------------------------------------------
; rest (think) - the FATIGUE / REST aspect: a real physiological fatigue model
; drives when an NPC sleeps.
;
; Sleepiness = (fatigue + the body clock's pressure) * (1 - adrenaline), derived by
; run_physiology (funcs/physiology.mc). Fatigue is the untouched debt, the clock pulls bedtime and
; waking toward the man's own chronotype, and a combatant reads ~0 until the surge fades.
;
; Two rules:
;   - sleep        : sleepy -> go-to-bed (tasks/go-to-bed-task.mc), which goes home to a
;                    bedroom and SLEEPs there. A normal day crosses the gate near 23:00 on his
;                    own clock; a night's unslept debt crosses it in the day, and that is a nap.
;   - idle-go-home : the mild fallback - when nothing pulls you, drift home.
; ----------------------------------------------------------------------------

(include "../../../macros/intensity-macros.mc")
(include "../../../macros/physiology-macros.mc")

; NEED from the gate, CRISIS past the collapse knee, so an exhausted man abandons everything
; and beds down.
(think sleep
  (role @self {@self sleepiness ?sleepiness}
    (role ?home {@self home ?home}
      (when (> ?sleepiness (sleep_gate)))
      (utility (homeostatic-banded ?sleepiness 2.0
                 [/need   0.8  400 900]
                 [/crisis 1.0  800 1000]))
      (effects (maintain-proposal {@self go-to-bed ?home})))))

; the mild fallback: anywhere but home with nothing else eligible -> drift home.
(think idle-go-home
  (role ?home {@self home ?home}
              (not (spatial @self building ?home))
    (utility idle fallback)
    (effects (maintain-proposal {@self go ?home}))))
