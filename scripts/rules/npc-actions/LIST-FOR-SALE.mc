; ----------------------------------------------------------------------------
; LIST-FOR-SALE ?building - put a building @self owns up for sale: its deed goes on every
; for-sale listing, and he knows it is on the market. Whether to sell is the proposer's.
; ----------------------------------------------------------------------------

(npc-action {@self LIST-FOR-SALE ?building}:?lfs-rel
  (tar [k building] @object)
  (motor body legs)
  (duration (seconds 30 min))
  (effects
    (list-for-sale ?building)
    (begin-belief {?building availability [k for-sale]})
    (set-outcome ?lfs-rel /succ)))
