; ----------------------------------------------------------------------------
; stow (npc-think lane) - the drive/travel thinks of the CARRY-IT-HOME-AND-PUT-
; IT-AWAY chain. The completion act lives in npc-act/stow.hs.
;
; Anything an NPC resolves to squirrel away rides ONE mechanism: a think mints
; {@self goal {@self stow <item>}} (the item is already in hand - a take-act
; put it there), and this chain drains it:
;
;   stow_go     : holding the goal, not at home -> travel home. The loot / the
;                 bloody knife is physically CARRIED (gripped_by rides the
;                 hand), so the world sees a laden walker, not a teleport. AT home the
;                 go sub-goal is spent, the stow goal is the leaf and promotes to
;                 stow_act (npc-act/stow.hs) - no dwell rung.
;
; A homeless NPC never fires stow_go; the item simply stays in hand (it rides
; them) and the goal stands - the same degenerate case the old C++ kept.
; Utility sits just above the burgle chain so a laden thief carries the loot home
; before hunting the next mark.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")
(include "../../../macros/tunables.mc")

; want_stow (npc-think) - OWNS the stow goal end to end. The theft act records the take
; as {@self carrying_loot ?item} (own state); this self-gate binds that item and holds the
; standing {@self stow ?item} goal while the loot is in hand. Its falling edge is stow_act
; putting the loot away and ending carrying_loot, which retires the goal. The acts never
; mint or end the goal - they only write the possession state the minter reads.
(npc-think want_stow
  (role @self {@self carrying_loot ?item})
  (utility errand always-pick)
  (effects       (begin-goal {@self stow ?item}))
  (cease-effects (end-goal   {@self stow ?item})))

(npc-think stow_go
  (goal {@self stow ?item})
  (role ?home {@self home ?home})
  (when (and ?item
             (not (at-home))))
  (effects (maintain-proposal {@self enter ?home})))

; AT home: PROPOSE the put-away act (goals never propose themselves). stow_act reads the carried
; item off the standing {@self stow} goal and ends it, so the propose is label-only.
(npc-think stow_at_home
  (goal {@self stow ?item})
  (when (and ?item
             (at-home)))
  ; The put-away place is DECIDED here: a fashioned hiding spot for a
  ; worth-hiding item (priced above the loot floor), else 0 (the body puts
  ; it openly in the room it stands in).
  (effects
    (if (and (> (price ?item) (valuable_loot_price_min)) {@self hiding_spot ?})
              (then (any {@self hiding_spot ?}).target)
              (else 0)): ?place
    (maintain-proposal {@self stow ?item ?place})))
