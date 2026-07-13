; ----------------------------------------------------------------------------
; stow (npc-think lane) - the drive/travel thinks of the CARRY-IT-HOME-AND-PUT-
; IT-AWAY chain. The completion act lives in npc-act/stow.hs.
;
; Anything an NPC resolves to squirrel away rides ONE mechanism: a think mints
; {@self goal {@self stow <item>}} (the item is already in hand - a take-act
; put it there), and this chain drains it:
;
;   stow_go     : holding the goal, not at home -> travel home. The loot / the
;                 bloody knife is physically CARRIED (controlled_by rides the
;                 hand), so the world sees a laden walker, not a teleport.
;   stow_put    : at home -> the short put-away act.
;
; A homeless NPC never fires stow_go; the item simply stays in hand (it rides
; them) and the goal stands - the same degenerate case the old C++ kept.
; Utilities sit just above the burgle chain (85/86) so a laden thief carries
; the loot home before hunting the next mark.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think stow_go
  (short-term-think)
  (goal {@self stow})
  (role ?home (believes {@self home ?home}))
  (bind (goal-focus stow) ?item)
  (when (and (is-entity ?item)
             (not (at-home))))
  (utility 90)
  (cont-fire-effects (go-into ?home)))

(npc-think stow_put
  (short-term-think)
  (goal {@self stow})
  (when (and (is-entity (goal-focus stow))
             (at-home)))
  (utility 91)
  (cont-fire-effects (begin-goal {@self stow})))
