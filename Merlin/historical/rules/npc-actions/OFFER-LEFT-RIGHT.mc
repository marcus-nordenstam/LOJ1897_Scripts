(include "../../definitions/roles.mc")

; offer ?thing to ?recipient - transfer @self's grip straight into the recipient's
; named hand. ?recipient-hand is a HAND ENTITY read via the struct label
; (spatial ?recipient left_hand /env); the grip store is excl, so the write atomically
; drops @self's grip (no detach op). Punctual (duration 0) - a private handoff.
(define-macro offer-effects (?recipient-hand ?thing ?recipient ?offer-action)
  (do
    (check (= (spatial ?thing held_by) @self))
    (check (spatial @self co-located ?recipient))
    (check (empty (spatial ?recipient-hand grip /env)))
    (spatial-write ?thing gripped_by ?recipient-hand /env)
    (set-outcome ?offer-action /succ)))

(npc-action {@self OFFER_LEFT ?thing ?recipient}:?offer-action-rel
  (tar object) (aux human) (duration 0)
  (effects (offer-effects (spatial ?recipient left_hand /env) ?thing ?recipient ?offer-action-rel)))

(npc-action {@self OFFER_RIGHT ?thing ?recipient}:?offer-action-rel
  (tar object) (aux human) (duration 0)
  (effects (offer-effects (spatial ?recipient right_hand /env) ?thing ?recipient ?offer-action-rel)))
