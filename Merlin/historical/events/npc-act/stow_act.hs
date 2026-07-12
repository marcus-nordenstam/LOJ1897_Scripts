; ----------------------------------------------------------------------------
; stow (npc-act lane) - the completion act of the CARRY-IT-HOME-AND-PUT-IT-AWAY
; chain. The thinks that drive it live in npc-think/stow.hs.
;
;   stow_act    : completion - put the item into the hiding spot when one
;                 exists ({@self hiding_spot ?cache}, make_secret_cache.hs
;                 fashions one for anyone with something to hide), else openly
;                 into the room the NPC stands in. Goal ends.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-act stow_act
  (when (believes {@self stow}))
  (duration 5)
  (act-effects
    (bind (goal-focus stow) ?item)
    (if (is-entity ?item)
        (do
          ; (target {..}) op-binds (@fail when no cache exists) - a plain
          ; pattern-bind would leave ?cache unbound on a miss and error.
          ; Only VALUABLES go into the hiding spot (the thief's loot, the
          ; heirloom); ordinary carry-home items (the cook's provisions)
          ; are put away openly in the room the NPC stands in.
          (bind (target {@self hiding_spot ?}) ?cache)
          (if (and (is-entity ?cache) (has-facet ?item valuable))
              (put-item ?item ?cache)
              (put-item ?item (attr @self location)))))
    (end-act {@self stow})
    (end-goal {@self stow})))
