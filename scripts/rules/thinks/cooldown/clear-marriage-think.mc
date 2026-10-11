; ----------------------------------------------------------------------------
; clear-marriage - instrumental homicide: a married man with a covert lover who is free to
; marry wants the lover, and the obstacle is his own spouse. Calculating rather than enraged,
; so it carries its own dark floor (psychopathy x machiavellianism) and no rage gate; the
; drive is attraction to the lover over warmth to the spouse. It mints the intent to kill the
; spouse, caused by his desire for the lover, so the intent fades as the desire does.
; pursue-kill (thinks/hot/kill-think.mc) chooses the means. Siblings: crime-of-passion,
; betrayal-kill, rid-of-spouse.
; ----------------------------------------------------------------------------

(intender clear-marriage
  (cooldown 1 m try-once)
  (rng-stream perpetration)

  (role @self {@self psychopathy ?psychopathy}
              {@self machiavellianism ?machiavellianism}
              {@self compassion ?compassion}
              {@self inhibition ?inhibition}
    (role ?spouse {?spouse isa [k human], condition [k alive]} {@self spouse ?spouse}
                  (select (policy first-match))
      (role ?paramour {?paramour isa [k human], condition [k alive]}
                      {@self lover ?paramour}
                      {@self desire|crave ?paramour}:?want
                      -{@self spouse ?paramour}
                      -{?paramour spouse ?}
                      (select (policy first-match))
        (when (and (>= (* ?psychopathy ?machiavellianism) 0.36)
                   (>= (- (stance-band ?paramour attraction) (stance-band ?spouse warmth)): ?drive 2.0)
                   (latch-eval (chance
                     (* (crime-scale) 0.03
                        (* ?psychopathy
                           (* ?machiavellianism
                              (* (- 1.0 ?inhibition)
                                 (* (- 1.0 ?compassion) ?drive)))))))))
        (declare-utility want)
        (effects
          (maintain-intent {@self intent {@self kill ?spouse}} /caused_by ?want))))))
