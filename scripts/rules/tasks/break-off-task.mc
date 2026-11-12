; ----------------------------------------------------------------------------
; break-off ?lover - end an affair: tell the lover it is over, a jilt-class line the jilted
; construes as abandonment and a wrong (reflexes/construe-speech.mc), then end one's own lover
; bond. Proposed by jilt and jilt-for-station (drivers/jilt-driver.mc).
; ----------------------------------------------------------------------------

(task {@self break-off ?lover}:?break-off
  (tar [k human] @object)
  (and
    (try
      (belief -{@self tell ? ?lover /succ /caused_by ?break-off}
        (effects (maintain-proposal {@self tell (formulaic /jilt [] breakup) ?lover}))))
    (try
      (belief {@self tell ? ?lover /succ /caused_by ?break-off}
        (effects
          (end-belief {@self lover ?lover})
          (set-outcome ?break-off /succ))))))
