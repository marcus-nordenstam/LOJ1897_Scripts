; ----------------------------------------------------------------------------
; consume - the npc-ACT half of the UNIFIED eat lane (the desires live in
; npc-think/meals.hs). Destroy ONE thing eaten + relieve hunger.
;
; Generic - the WHICH (carried / home pantry / a shop's stock) is decided
; think-side (forage_at_source in meals_think.hs); the act receives the chosen
; ?item + the wronged ?owner off its pattern and does no reasoning. ?owner is 0
; when the food is the eater's own; a non-zero ?owner is a STOLEN mouthful and
; lands on the crime ledger.
; ----------------------------------------------------------------------------

(include "../../macros/collection_macros.hs")

(npc-action {@self CONSUME ?item ?owner}
  (duration 10)
  (effects
    ; ?item is a food PILE (basket / larder / shelf) - eat one off the count, the
    ; pile stands - OR a loose loaf (legacy) - destroy it.
    (if (is-a ?item [k pile])
        (then (pile-take ?item 1))
        (else (realize-destroyed ?item condition [k condition consumed])
              (destroy-entity ?item)))
    (set-attr @self hunger (max 0 (- (attr @self hunger) 0.5)))
    (if ?owner
        (then (crime-ledger-append @self ?owner steal steal @u @u)))
    (set-outcome {@self CONSUME ?item ?owner} succ)))
