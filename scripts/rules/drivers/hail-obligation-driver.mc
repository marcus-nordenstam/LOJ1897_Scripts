; ----------------------------------------------------------------------------
; hail-obligation - a man who owes another a hail, having turned his down while busy
; (reflexes/obligation-hail.mc), hails him once nothing he has going outbids it: it is worth what
; taking his hail up was (hail-utility), so whatever was keener then is keener still while it
; lasts, and the hail waits for its end rather than for a clock.
; ----------------------------------------------------------------------------

(driver hail-obligation-driver
  (role ?hailer {@self obligation {@self hail ?hailer} ?hailer}:?owed
    (bind (hail-utility ?hailer) ?utility)
    (declare-utility (utility-band ?utility) (utility-value ?utility))
    (when (and (within-call ?hailer)
               (not (conversing-with ?hailer))
               (hailable ?hailer)))
    (effects (maintain-proposal {@self hail ?hailer} /caused_by ?owed))))
