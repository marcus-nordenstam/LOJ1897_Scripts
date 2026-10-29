; ----------------------------------------------------------------------------
; rest (drivers) - the FATIGUE / REST aspect: a real physiological fatigue model
; drives when an NPC sleeps.
;
; A man knows his tiredness only as his {@self alertness <band>}, which run_physiology
; (funcs/physiology.mc) mints from his masked sleepiness.
;
; Two rules:
;   - sleep        : tired or sleepy -> go-to-bed (tasks/go-to-bed-task.mc), which goes home to
;                    a bedroom and SLEEPs there; a need while tired, a crisis once sleepy. A
;                    night's unslept debt tires him in the day, and that is a nap.
;   - idle-go-home : the mild fallback - when nothing pulls you, drift home.
; ----------------------------------------------------------------------------

(include "../../macros/intensity-macros.mc")

(driver sleep-driver
  (role @self {@self alertness [k tired|sleepy]}
    (role ?home {@self home ?home}
      (declare-utility (flip {@self alertness [k sleepy]} crisis need) default)
      (effects (maintain-proposal {@self go-to-bed ?home})))))

; the mild fallback: anywhere but home with nothing else eligible -> drift home.
(driver idle-go-home-driver
  (role ?home {@self home ?home}
              (not (spatial @self unit ?home))
    (declare-utility idle fallback)
    (effects (maintain-proposal {@self go-to ?home}))))
