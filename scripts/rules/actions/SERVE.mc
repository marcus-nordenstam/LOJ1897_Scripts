; ----------------------------------------------------------------------------
; SERVE ?pile ?hand - one portion off a food pile within reach into ?hand: a whole food item of the
; pile's dish (its content kind when it has none), a meal's bites, and the pile one fewer. Food
; kept in a pile is eaten only once it is served: EAT eats a whole item, never a pile.
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
    (check (>= (attr ?pile count) 1))
    (bind (attr ?pile dish) ?dish)
    (create-entity (flip (substantial ?dish) ?dish (attr ?pile content-kind)) (spatial @self space /env)): ?portion
    (set-attr ?portion bites (serving_bites))
    (pile-add ?pile -1)
    (grip-into-hand ?portion ?hand)
    (observe ?pile)
    (set-outcome ?SERVE /succ)))
