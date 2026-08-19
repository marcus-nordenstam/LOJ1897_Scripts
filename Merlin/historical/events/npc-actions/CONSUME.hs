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

(npc-action {@self CONSUME ?item ?owner}
  (duration 10)
  (effects
    (realize-destroyed ?item condition [k condition consumed])
    (destroy-entity ?item)
    (set-attr @self hunger (max 0 (- (attr @self hunger) 0.5)))
    (if ?owner
        (then (crime-ledger-append @self ?owner steal steal @u @u)))
    (set-outcome {@self CONSUME ?item ?owner} succ)))
