; ----------------------------------------------------------------------------
; propose-marriage ?partner - go to her and tell her they are betrothed; told, he holds the
; betrothal himself, and she holds it in hers (fiancee-reciprocate, thinks/wed-think.mc).
; PREPARATION for a wedding, so only a driver proposes it.
; ----------------------------------------------------------------------------

(task {@self propose-marriage ?partner}:?propose-marriage
  (belief-timeout 15 min)
  (tar [k human] @object)
  (preparatory)
  (preemptive-or
    (try
      (belief {@self SAY ? ?partner /succ /caused_by ?propose-marriage}
        (effects
          (begin-belief {@self fiancee ?partner})
          (set-outcome ?propose-marriage /succ))))
    (try
      (effects (maintain-intent {@self intent {@self SAY (msg /utterable [] {@self fiancee ?partner}) ?partner}})))))
