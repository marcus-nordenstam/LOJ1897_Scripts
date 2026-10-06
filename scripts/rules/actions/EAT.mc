; ----------------------------------------------------------------------------
; eat - the npc-ACT of eating ONE mouthful of food (the opportunistic-forage desires
; live in thinks/meals.mc; the scheduled-meal sitting in tasks/eat-task.mc). The
; physical eating for both chains: destroy one food + relieve hunger, theft-recorded
; when the mouthful is not the eater's own.
;
; Generic - the WHICH (carried basket / home larder / a shop's shelf / an abstract
; bought meal) is decided think-side (forage_at_source in meals_think, the take_meal
; rung in eat-task) and handed in; the act does no reasoning:
;   ?food  - the food PILE (basket / larder / shelf) to eat one off the count, OR a
;            loose loaf (legacy) to destroy, OR 0 for an abstract meal (nothing to
;            destroy - breakfast / lunch / a bought-out supper).
;   ?owner - the wronged party when the mouthful is STOLEN (a shop's stock, no wealth);
;            0 when the food is the eater's own. A non-zero ?owner lands on the crime
;            ledger. Meal length + satiety are the eat TASK's concern (its meal-typed
;            utility), not the act's.
; ----------------------------------------------------------------------------

(include "../../macros/collection-macros.mc")

(action {@self EAT ?food ?owner}
  (motor body legs)
  (duration (seconds 30 min))
  (effects
    (if ?food
        (then (if (is-a ?food [k pile])
                  (then (set-attr ?food count (max 0 (- (attr ?food count) 1))))
                  (else (do
                          (end-beliefs-about ?food [/exclude condition|internment|EAT])
                          (begin-belief {?food condition [k consumed]}))
                        (destroy-entity ?food)))))
    (set-attr @self hunger (max 0.0 (- (attr @self hunger) 0.5)))
    (if ?owner
        (then (record-crime @self ?owner steal steal @u @u)))
    (set-outcome {@self EAT ?food ?owner} /succ)))
