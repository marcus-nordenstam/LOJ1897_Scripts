; ----------------------------------------------------------------------------
; consummate (npc-action lane) - the durative intimate act of an affair. The
; think half (npc-think/hot/affair_consummate.hs) decides - whenever two lovers
; are co-present and it is discreet enough - and PROMOTES this act; here the act
; RUNS for its duration, which is what holds both lovers co-present long enough
; for the tryst to land (and long enough for a prying servant to catch them).
;
; The begun-then-ended {@self HAVE-SEX-WITH ?paramour} act-belief IS the record on
; the actor's side (the engine ends it here at completion, stamping the interval);
; this body writes the reciprocal record on the paramour and advances the mutual
; attraction. HAVE-SEX-WITH carries the (abduct) decoration, so committing it lets
; a co-present witness abduce the {cheater lover paramour} bond.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

; ~45 minutes: a real dwell, not an instant. Both lovers run their own copy
; (each sees the other as a co-present lover), so both are held for the window.
(npc-action {@self HAVE-SEX-WITH ?paramour}
  (duration 45)
  (effects
    (debug-print "CONSUMMATE_ACT_DONE @self para=?paramour")
    ; The reciprocal act-record on the paramour (the actor's own side is the
    ; begun-then-ended running act-belief, auto-ended at completion).
    (begin-ended-belief ?paramour {?paramour HAVE-SEX-WITH @self})
    ; The tryst advances the affair on both sides.
    (nudge-stance @self ?paramour attraction 0.10)
    (nudge-stance ?paramour @self attraction 0.10)
    (set-outcome {@self HAVE-SEX-WITH ?paramour} /succ)))
