; ----------------------------------------------------------------------------
; PILE-TRANSFER ?held ?into - empty a pile held in hand into another pile of the same
; content within reach. The emptied pile is gone: what was in the hand is now in ?into.
; ----------------------------------------------------------------------------

(action {@self PILE-TRANSFER ?held ?into}:?PILE-TRANSFER
  (motor right-hand legs)
  (duration (seconds 1 min))
  (effects
    (check (= (spatial ?held held-by) @self))
    (check (within-reach ?into))
    (check (attr-is ?into content-kind (attr ?held content-kind)))
    (pile-add ?into (attr ?held count))
    (destroy-entity ?held)
    (set-outcome ?PILE-TRANSFER /succ)))
