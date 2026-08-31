; ----------------------------------------------------------------------------
; npc_default_spawns.mc - default character appearance for hsim-created NPCs.
;
; hsim-created NPCs (the murder victim / body, townsfolk, anyone the player
; walks up to) carry NO authored presentation. This table picks the default
; character .spawn each one renders as, by gender + class-situation.
;
; Read GRYM-side (the Player's ProximityPresenter, Espresso's Converse mode)
; through the mc definition coordinator - the one parser for every .mc data
; file. The .spawn files are GrymEngine content assets, so the selection lives
; in the engine, not Merlin - this file is just the data.
;
;   gender - matches the NPC's `gender` attr.
;   class  - matches the NPC's `class-situation` attr (upper / middle / lower).
;   file   - resolves against the project Content/Spawn directory.
;
; `any` in gender or class is a WILDCARD. Rows are tried top-to-bottom; the FIRST
; whose every non-wildcard filter matches wins - so list specific rows before the
; per-gender catch-alls.
;
; (Age / role refinement can be added later as extra fields; a reader that does
; not know a field ignores it, so adding one is additive.)
; ----------------------------------------------------------------------------

(define-table npc_default_spawns
  (fields gender class file)

  ; -- female (only FM_LowClass / FM_MidClass spawns exist; upper borrows MidClass) --
  (record female upper  FM_MidClass_01.spawn)
  (record female middle FM_MidClass_02.spawn)
  (record female lower  FM_LowClass_01.spawn)
  (record female any    FM_LowClass_01.spawn)

  ; -- male --
  (record male   upper  Male_Medium_UpperClass_01.spawn)
  (record male   middle Male_Medium_MiddleClass_01.spawn)
  (record male   lower  Male_Medium_WorkingClass_01.spawn)
  (record male   any    Male_Medium_WorkingClass_01.spawn))
