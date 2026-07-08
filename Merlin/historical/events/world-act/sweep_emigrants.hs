; ----------------------------------------------------------------------------
; sweep_emigrants.hs - monthly emigrant cleanup. ZERO-ROLE world sweep: it only
; changes the world's bookkeeping (clear out NPCs who have decided to leave), it
; does not cast or deliberate for any NPC. (sweep-emigrants) self-enumerates every
; entity carrying the emigrating marker (set per-NPC by (mark-emigrating @self) in
; the emigration think event), takes each off org rosters, returns their residence
; to the housing market, drops them from the co-presence index, and destroys them
; (an emigrant left the world - no corpse, no burial). It collects the set FIRST
; and destroys AFTER the walk (destroying mid mx_for_each_entity would corrupt the
; iteration - the role-walk-corruption gotcha).
;
; This is the SWEEP half of the mark-then-sweep pattern, the exact twin of
; burial.hs: death and emigration are both marked PER-NPC but swept zero-role,
; because the entity being removed cannot remove itself.
; ----------------------------------------------------------------------------

(hsim-world-event sweep_emigrants
  (schedule (monthly))
  (rng-stream migrations)

  (effects
    (sweep-emigrants)
    ))
