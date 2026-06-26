; ----------------------------------------------------------------------------
; burial.hse - PR-evi-B 2026-05-25.
;
; Monthly cleanup pass: walk every condition=dead NPC whose death_date is
; at least one month in the past and call (bury) to destroy the entity.
;
; The corpse-persistence window exists to let coroner / physician minds
; examine a corpse (PR-evi-B EXAMINE.act) before it disappears. Without
; this event the corpse leaks an entity slot (mortality_disease /
; terminal_kill_victim used to destroy immediately pre-PR-evi-B; that
; responsibility has moved here).
;
; The role filter (>= (months-since-death ?dead) 1) ensures at least one
; monthly tick has elapsed between death and burial - same-month deaths
; are skipped, the corpse survives to next month. Worst-case persistence
; ~60 days (death day 1 of month N, burial day 1 of month N+2 when
; rounding bites); best-case ~28 days (death day 28 of month N, burial
; day 1 of month N+1).
;
; (bury) is a no-op for already-destroyed entities (defensive against
; double-bury from any future caller) and for non-dead entities (defensive
; against authoring errors).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event burial
  (schedule (monthly))
  (rng-stream burials)

  ; Inline role - NOT (template any_human), because that template includes
  ; (alive) and we specifically want the DEAD corpses. Bare (kind human)
  ; gives us every human archetype member; the condition / age filters
  ; narrow to old-enough corpses.
  (roles
    (role ?dead (kind [k human])
                (= (attr ?dead condition) [k dead])
                (>= (months-since-death ?dead) 1)))

  (effects
    (bury ?dead)
    ))
