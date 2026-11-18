; ----------------------------------------------------------------------------
; take-lover ?lover - become someone's lover: tell them so ({@self lover ?lover}), then share the
; friend-tier profile, then hold the bond oneself, grounded in attraction. The lover hears it and
; decides in their own mind (accept-lover, thinks/accept-lover-think.mc). Proposed by lovers
; and affair (drivers/).
; ----------------------------------------------------------------------------

(include "../../macros/affair-macros.mc")

(task {@self take-lover ?lover}:?take-lover
  (belief-timeout 2 h)
  (tar [k human] @object)
  (sequence
    (belief {@self name ?}
      (stage
        (effects
          (if -{@self SAY ? ?lover /succ /caused_by ?take-lover}
              (then (maintain-intent {@self intent {@self SAY (msg /utterable [] {@self lover ?lover}) ?lover}})))))
      (stage
        (effects
          (every {@self (disclosure-tier-labels friend self-disclosable) ?}): ?facts
          (if ?facts
              (then (maintain-intent {@self intent {@self SAY (msg /utterable [] ?facts) ?lover}})))))
      (stage
        (effects
          (begin-belief {@self lover ?lover})
          (feel-stance ?lover attraction (lover-attraction-felt))
          (set-outcome ?take-lover /succ))))))
