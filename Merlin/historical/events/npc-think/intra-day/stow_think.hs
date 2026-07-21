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
;                 hand), so the world sees a laden walker, not a teleport. AT home the
;                 go sub-goal is spent, the stow goal is the leaf and promotes to
;                 stow_act (npc-act/stow.hs) - no dwell rung.
;
; A homeless NPC never fires stow_go; the item simply stays in hand (it rides
; them) and the goal stands - the same degenerate case the old C++ kept.
; Utility sits just above the burgle chain so a laden thief carries the loot home
; before hunting the next mark.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think stow_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self stow ?item})
  (role ?home (believes {@self home ?home}))
  (when (and (is-entity ?item)
             (not (at-home))))
  (utility 90)
  (effects       (begin-goal {@self enter ?home}))
  (cease-effects (end-goal   {@self enter ?home})))
