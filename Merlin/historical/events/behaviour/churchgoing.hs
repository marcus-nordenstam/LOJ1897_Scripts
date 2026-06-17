; ----------------------------------------------------------------------------
; churchgoing - an F3.7 behaviour seed event. Once a year a share of adults
; attend the parish church, gaining a `worship` belief. The F3.5 piety
; classifier reads it (v1 piety is binary - churchgoer vs not). The
; (go-to-church ...) verb locates the church building itself, so the event
; needs only the ?npc role.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event churchgoing
  (nl         "?npc attends church")
  ; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
  ; MONTHLY, so the formerly-annual (chance) is /12 to hold the annual rate
  ; (0.4 -> 0.0333). The worship belief is idempotent (binary piety), so the
  ; re-fires are harmless; congregation co-presence comes from the itinerary.
  (rng-stream behaviour)

  (roles
    ; High politeness (respect for convention and institution) attends church
    ; more often. Mean-1.0 multiplier - attendance volume is unchanged.
    (role ?npc (template old_human)
               (chance (* 0.0333 (+ 0.5 (attr ?self politeness))))))

  (effects
    (go-to-church ?npc)
    (log _churchgoing ?npc)))
