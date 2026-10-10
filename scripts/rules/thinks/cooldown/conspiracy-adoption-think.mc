; ----------------------------------------------------------------------------
; conspiracy-adoption - taking up a murder another man intends, learned by being told.
;
; hire-assassin (tasks/hire-assassin-task.mc) tells the man it solicits the instigator's
; intent, {<instigator> intent kill <victim>}, which he adopts in his own mind. THIS rule is
; the decision to comply: he desires the instigator (attraction band >= 2) and is dark
; enough, so he takes on the accomplice bond and an intent of his own to kill the victim,
; caused by that bond - both sourced to what he was TOLD, never to a cross-mind mint.
; ----------------------------------------------------------------------------


(intender conspiracy-adoption
  (cooldown 1 m try-once)
  (rng-stream perpetration)
  (role @self {@self psychopathy ?psychopathy}
    (role ?instigator {?instigator isa [k human], condition [k alive]}
                      {@self desire|crave ?instigator}
                      (!= ?instigator @self)
      (role ?victim {?victim isa [k human], condition [k alive]}
                    {?instigator intent {?instigator kill ?victim}}:?their-intent
                    -{?victim condition [k dead]}
                    (!= ?victim @self)
        (when (and (>= (stance-band ?instigator attraction) 2.0)
                   (latch-eval (chance ?psychopathy))))
        (declare-utility want)
        (effects
          (if -{@self accomplice ?instigator}
              (then (begin-belief {@self accomplice ?instigator ?their-intent})))
          (any {@self accomplice ?instigator}): ?accomplice
          (maintain-intent {@self intent {@self kill ?victim}} /caused_by ?accomplice))))))
