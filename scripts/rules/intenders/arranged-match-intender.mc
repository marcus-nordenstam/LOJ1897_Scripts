; ----------------------------------------------------------------------------
; arranged-match - a father whose life aims at respectability or wealth resolves to marry an
; unmarried daughter to a man of his own class. pursue-arrange-match carries it out
; (tasks/arrange-match-task.mc): the daughter is told to wed him or be disinherited, and both
; are told they are betrothed.
; ----------------------------------------------------------------------------

(intender arranged-match
  (cooldown 1 m try-once)
  (rng-stream marriages)
  (role @self {@self life-aim [k respectability-aim|wealth-aim]}:?aim
              {@self class-situation ?class}
    (role ?daughter {?daughter isa [k human], condition [k alive]}
                    {@self child ?daughter}
                    {?daughter gender [k female]}
                    {?daughter age-band [k young-adult]}
                    -{?daughter spouse ?}
                    -{?daughter fiancee ?}
                    (select (policy first-match))
      (role ?groom {?groom isa [k human], condition [k alive]}
                   {?groom gender [k male]}
                   {?groom name ?}
                   {?groom age-band [k young-adult|middle-aged]}
                   {?groom class-situation ?class}
                   -{?groom spouse ?}
                   -{?groom fiancee ?}
                   (none {@self (kin-labels) ?groom})
                   (select (policy first-match))
        (when (latch-eval (chance 0.02)))
        (declare-utility want)
        (effects (maintain-intent {@self intent {@self arrange-match ?daughter ?groom}} /caused_by ?aim))))))
