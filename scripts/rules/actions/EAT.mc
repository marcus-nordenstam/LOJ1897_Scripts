; ----------------------------------------------------------------------------
; EAT ?food ?owner - eat a whole food item, a dish, a meal, a fruit, bite by bite: each bite takes
; (bite_minutes) and its share of a meal's hunger relief, and the bite that finishes it is the act's
; /succ. Never a pile: food kept in one is served out of it first (SERVE). For now both LODs eat
; every bite left as the act concludes, so an EAT cut short leaves the item whole.
;
; ?food is @consumed: once eaten the memory holds its kind, {@self EAT [k pie]}, what he ate.
; ?owner is the wronged party when the food is STOLEN, 0 when it is his own; a non-zero ?owner
; lands on the crime ledger.
; ----------------------------------------------------------------------------

(include "../../macros/collection-macros.mc")
(include "../../macros/physiology-macros.mc")

(action {@self EAT ?food ?owner}:?EAT
  (construed-act sensual-act)
  (tar [k food] @object @consumed)
  (motor body)
  (belief-timeout 30 min)
  (duration (seconds (* (bite_minutes) (attr ?food bites)) min))
  (effects
    (check (spatial @self can-reach ?food /env))
    (set-attr @self hunger (max 0.0 (- (attr @self hunger) (* /float (bite_relief) (attr ?food bites)))))
    (set-attr ?food bites 0)
    (end-beliefs-about ?food [/exclude condition|internment|EAT])
    (begin-belief {?food condition [k consumed]})
    (destroy-entity ?food)
    (if ?owner
        (then (record-crime @self ?owner steal steal @u @u)))
    (set-outcome ?EAT /succ)))
