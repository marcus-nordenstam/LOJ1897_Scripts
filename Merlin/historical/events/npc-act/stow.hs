; ----------------------------------------------------------------------------
; stow.hs - the generic CARRY-IT-HOME-AND-PUT-IT-AWAY lane.
;
; Anything an NPC resolves to squirrel away rides ONE mechanism: a think mints
; {@self goal {@self stow <item>}} (the item is already in hand - a take-act
; put it there), and this chain drains it:
;
;   stow_go     : holding the goal, not at home -> travel home. The loot / the
;                 bloody knife is physically CARRIED (controlled_by rides the
;                 hand), so the world sees a laden walker, not a teleport.
;   stow_put    : at home -> the short put-away act.
;   stow_finish : completion - put the item into the hiding spot when one
;                 exists ({@self hiding_spot ?cache}, make_secret_cache.hs
;                 fashions one for anyone with something to hide), else openly
;                 into the room the NPC stands in. Goal ends.
;
; A homeless NPC never fires stow_go; the item simply stays in hand (it rides
; them) and the goal stands - the same degenerate case the old C++ kept.
; Utilities sit just above the burgle chain (85/86) so a laden thief carries
; the loot home before hunting the next mark.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event stow_go
  (intra-day)
  (bind (goal-focus stow) ?item)
  (when (and (has-goal stow)
             (is-entity ?item)
             (bind {@self home ?home})
             (not (at-home))))
  (utility 90)
  (effects (go @self ?home)))

(hsim-event stow_put
  (intra-day)
  (when (and (has-goal stow)
             (is-entity (goal-focus stow))
             (at-home)))
  (utility 91)
  (effects (act stow_finish 5)))

(hsim-event stow_finish
  (schedule (completion-only))
  (effects
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
    (end-goal {@self stow})))
