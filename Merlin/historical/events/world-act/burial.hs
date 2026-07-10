; ----------------------------------------------------------------------------
; burial.hs - monthly corpse cleanup. ZERO-ROLE world sweep: it changes only the
; world's bookkeeping (clear out stale corpses), it does not cast or deliberate
; for any NPC. (sweep-burials) self-enumerates every condition=dead corpse whose
; death is >= 1 month past and buries each (verdict ledger + tombstone + destroy),
; collecting the set FIRST and destroying AFTER the walk (destroying mid
; mx_for_each_entity would corrupt the iteration).
;
; The >= 1-month persistence window lets a coroner / physician examine a corpse
; (EXAMINE.act) before it disappears. Worst-case persistence ~60 days, best ~28.
;
; This stays a world-act because death is marked PER-NPC ((die @self) in the
; mortality think events) but the corpse - a mindless, deliberation-less entity -
; cannot bury itself; sweeping the dead is genuine world bookkeeping.
; ----------------------------------------------------------------------------

(world-event burial
  (schedule (monthly))
  (rng-stream burials)

  (effects
    (sweep-burials)
    ))
