; ----------------------------------------------------------------------------
; STOCK-LARDER ?spot ?basket - a STOPGAP for the whole household shopping errand.
;
; The real errand - the cook knows a shop that sells provisions, goes there, buys a basket
; (PROVISION) and carries it home to the kitchen (carry-home) - is not built out yet. Until it
; is, the cook goes to his own kitchen (tasks/stock-larder-task.mc) and the basket he would
; have bought appears in the larder: a lie about where food comes from, but a true statement
; about there being some.
;
; DELETE THIS FILE and tasks/stock-larder-task.mc when shopping works, and have
; want-provisions-driver propose provision again.
; ----------------------------------------------------------------------------

(include "../../macros/collection-macros.mc")

; ?spot is the kitchen floor spot the proposing rung holds for a new pile; ?basket is what the
; errand would have bought (provision-basket), decided think-side.
(action {@self STOCK-LARDER ?spot ?basket}:?STOCK-LARDER
  (construed-act toil-act)
  (motor body)
  (duration (seconds 5 min))
  (effects
    (spatial @self space /env): ?kitchen
    (check (is-a ?kitchen [k kitchen]))
    (bind 0 ?pile)
    (for-each ?pile_cand (spatial ?kitchen contents [k pile] /env)
      (if (attr-is ?pile_cand content-kind [k food])
          (then (bind ?pile_cand ?pile))))
    (if (not ?pile)
        (then (create-entity [k pile] ?spot): ?pile
              (set-attr ?pile content-kind [k food])
              (set-attr ?pile count 0)))
    (set-attr ?pile count (+ (attr ?pile count) ?basket))
    ; What the household eats until the next basket: one dish, drawn afresh each time it is filled.
    (set-attr ?pile dish (table-sample-weighted food_particulars particular draw))
    ; He filled it himself, so he knows it is there - without this the pile exists and
    ; the larder still reads empty to the only mind that matters.
    (observe ?pile)
    (set-outcome ?STOCK-LARDER /succ)))
