; ----------------------------------------------------------------------------
; take-lover ?lover - become someone's lover: tell them so ({@self lover ?lover}), then share the
; friend-tier profile, then hold the bond oneself, grounded in attraction. The lover hears it and
; decides in their own mind (accept-lover, thinks/hot/accept-lover-think.mc). Proposed by lovers
; and affair (thinks/cooldown/).
; ----------------------------------------------------------------------------

(include "../../macros/affair-macros.mc")

(task {@self take-lover ?lover}:?take-lover
  (tar [k human] @object)
  (sequence
    (role @self {@self name ?}
      (stage
        (effects
          (if -{@self tell ? ?lover /succ /caused_by ?take-lover}
              (then (maintain-proposal {@self tell (utterable-msg [] {@self lover ?lover}) ?lover})))))
      (stage
        (effects
          (every {@self (disclosure-tier-labels friend) ?}): ?facts
          (if ?facts
              (then (maintain-proposal {@self tell (utterable-msg [] ?facts) ?lover})))))
      (stage
        (effects
          (begin-belief {@self lover ?lover})
          (nudge-stance ?lover attraction (lover_attraction_floor))
          (set-outcome ?take-lover /succ))))))
