; ----------------------------------------------------------------------------
; read_listings - the npc-ACT half of the purchase demand (buy_home.hs), promoted
; at a house agent's office.
;
;   read_listings : the KNOWLEDGE CHANNEL. Reads the PUBLIC for-sale register
;     (read-public-register, the foundation macro) so @self forms {@self for_sale
;     ?b} beliefs for every listing on file - this is how he LEARNS what is for
;     sale (no scan). choose_home (buy_home.hs) then casts over these beliefs.
; ----------------------------------------------------------------------------

(npc-action {@self READ_LISTINGS}
  (duration 30)
  (effects
    (read-public-register [k for_sale_listing] for_sale)
    (set-outcome {@self READ_LISTINGS} succ)))
