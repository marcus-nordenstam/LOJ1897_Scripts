; ----------------------------------------------------------------------------
; SERVE ?pile ?hand - one portion off a food pile within reach into ?hand: a whole food item of the
; pile's dish (its content kind when it has none), a meal's bites, and the pile one fewer. Food
; kept in a pile is eaten only once it is served: EAT eats a whole item, never a pile. A pile he
; believed stocked may be bare by the time he reaches it - another of the house ate it - and he
; finds it so: he looks at it and the act fails.
; ----------------------------------------------------------------------------

(include "../../macros/collection-macros.mc")
(include "../../macros/physiology-macros.mc")

(action {@self SERVE ?pile ?hand}:?SERVE
  (sided aux left-hand right-hand)
  (tar [k pile] @object)
  (duration (seconds 1 min))
  (effects
    (check (spatial @self can-reach ?pile /env))
    (check (empty (spatial ?hand grip /env)))
    (if (< (attr ?pile count) 1)
        (then (observe ?pile)
              (set-outcome ?SERVE /fail))
        (else
          (bind (attr ?pile dish) ?dish)
          (create-entity (flip (substantial ?dish) ?dish (attr ?pile content-kind)) (spatial ?hand bounds /env)): ?portion
          (set-attr ?portion bites (serving_bites))
          (pile-add ?pile -1)
          (grip-into-hand ?portion ?hand)
          (observe ?pile)
          (set-outcome ?SERVE /succ)))))
