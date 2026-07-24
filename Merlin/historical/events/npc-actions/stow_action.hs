; ----------------------------------------------------------------------------
; stow (npc-action lane) - the completion act of the CARRY-IT-HOME-AND-PUT-IT-AWAY
; chain. The thinks that drive it live in npc-think/stow.hs.
;
;   stow_action : completion - put the item into the hiding spot when one
;                 exists ({@self hiding_spot ?cache}, make_secret_cache_think.hs
;                 fashions one for anyone with something to hide), else openly
;                 into the room the NPC stands in. Goal ends.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self stow ?item}
  (duration 5)
  (effects
    (if (is-entity ?item)
        (then
          ; (target {..}) op-binds (@fail when no cache exists) - a plain
          ; pattern-bind would leave ?cache unbound on a miss and error.
          ; Only VALUABLES go into the hiding spot (the thief's loot, the
          ; heirloom); ordinary carry-home items (the cook's provisions)
          ; are put away openly in the room the NPC stands in.
          (bind (target {@self hiding_spot ?}) ?cache)
          (if (and (is-entity ?cache) (has-facet ?item valuable))
              (then (put-item ?item ?cache))
              (else (put-item ?item (attr @self location))))
          ; The put-away un-flags the loot: ending carrying_loot (own state) drops
          ; want_stow's self-gate, whose falling edge retires the {@self stow} goal.
          (end-belief {@self carrying_loot ?item})))
    (set-outcome {@self stow} succ)))
