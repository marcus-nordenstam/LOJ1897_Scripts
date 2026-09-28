; ----------------------------------------------------------------------------
; stock-larder - a STOPGAP, and the only thing in the corpus that fills a larder.
;
; The household supply run (npc-think/provisioning-think.mc) elects its cook - 47 of
; them - and then never reaches the shop, so no kitchen is ever stocked, every
; (believed-home-food-count ..) reads 0, and the whole meal aspect sits behind an empty
; larder while the town starves. Until that chain is resurrected a resident puttering
; through his own kitchen finds it stocked, which is a lie about where food comes from
; but a true statement about there being some.
;
; DELETE THIS FILE, and the putter rung that proposes it, when provisioning works.
; ----------------------------------------------------------------------------

(include "../../macros/collection-macros.mc")

; One household's keeping - a food prop is a person-day, so this is a family for a
; month, the cadence at which a puttering resident comes back round to the kitchen.
(define-macro larder_stopgap_stock () 30)

; ?spot is the kitchen floor spot the proposing rung holds for a new pile; the rung gives
; it back when it ceases, once the larder reads stocked.
(npc-action {@self STOCK-LARDER ?kitchen ?spot}
  (motor body legs)
  (duration (seconds 5 min))
  (effects
    (check (spatial @self space ?kitchen /env))
    (bind 0 ?pile)
    (for-each ?pile_cand (spatial ?kitchen contents [k pile] /env)
      (if (attr-is ?pile_cand content-kind [k food])
          (then (bind ?pile_cand ?pile))))
    (if (not ?pile)
        (then (create-entity [k pile] ?spot): ?pile
              (set-attr ?pile content-kind [k food])))
    (set-attr ?pile count (larder_stopgap_stock))
    ; He filled it himself, so he knows it is there - without this the pile exists and
    ; the larder still reads empty to the only mind that matters.
    (observe ?pile)
    (set-outcome {@self STOCK-LARDER ?kitchen ?spot} /succ)))
