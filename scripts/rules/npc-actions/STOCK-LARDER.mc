; ----------------------------------------------------------------------------
; stock-larder - a STOPGAP, and the only thing in the corpus that fills a larder.
;
; The household supply run (npc-think/provisioning-think.mc) elects its cook - 47 of
; them - and then never reaches the shop, so no kitchen is ever stocked, every
; (believed-home-food-count ..) reads 0, and the whole meal lane sits behind an empty
; larder while the town starves. Until that lane is resurrected a resident puttering
; through his own kitchen finds it stocked, which is a lie about where food comes from
; but a true statement about there being some.
;
; DELETE THIS FILE, and the putter rung that proposes it, when provisioning works.
; ----------------------------------------------------------------------------

(include "../../macros/collection-macros.mc")

; One household's keeping - a food prop is a person-day, so this is a family for a
; month, the cadence at which a puttering resident comes back round to the kitchen.
(define-macro larder_stopgap_stock () 30)

; ?cell is the kitchen floor cell the proposing rung holds for a new pile; the rung gives
; it back when it ceases, once the larder reads stocked.
(npc-action {@self STOCK-LARDER ?kitchen ?cell}
  (duration (seconds 5 min))
  (effects
    (check (spatial @self space ?kitchen /env))
    (bind 0 ?pile)
    (pile-at-into ?kitchen [k food] ?pile)
    (if (not ?pile)
        (then (create-entity [k pile] ?cell): ?pile
              (set-attr ?pile content-kind [k food])))
    (set-attr ?pile count (larder_stopgap_stock))
    ; He filled it himself, so he knows it is there - without this the pile exists and
    ; the larder still reads empty to the only mind that matters.
    (observe ?pile)
    (set-outcome {@self STOCK-LARDER ?kitchen ?cell} /succ)))
