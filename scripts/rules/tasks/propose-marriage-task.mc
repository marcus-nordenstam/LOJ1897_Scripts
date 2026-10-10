; ----------------------------------------------------------------------------
; propose-marriage ?partner - go to her and tell her they are betrothed; told, he holds the
; betrothal himself, and she holds it in hers (fiancee-reciprocate, thinks/hot/wed-think.mc).
; PREPARATION for a wedding, so only a driver proposes it.
; ----------------------------------------------------------------------------

(task {@self propose-marriage ?partner}:?propose-marriage
  (tar [k human] @object)
  (preparatory)
  (preemptive-or
    (try
      (when {@self tell ? ?partner /succ /caused_by ?propose-marriage})
      (effects
        (begin-belief {@self fiancee ?partner})
        (set-outcome ?propose-marriage /succ)))
    (try
      (effects (maintain-proposal {@self tell (utterable-msg [] {@self fiancee ?partner}) ?partner})))))
