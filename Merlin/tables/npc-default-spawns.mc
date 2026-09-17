; ----------------------------------------------------------------------------
; npc-default-spawns.mc - default character appearance for hsim-created NPCs.
;
; hsim-created NPCs (the murder victim / body, townsfolk, anyone the player
; walks up to) carry NO authored presentation. This table picks the default
; character .spawn each one renders as, by gender + class-situation.
;
; Read by (npc-spawn-file ?who) in funcs/presentation.mc, which the host calls
; through mx_call. The .spawn files are GrymEngine assets, but WHICH one a given
; man wears is a fact about him, so the choosing is content and lives here.
;
;   gender - matches the NPC's `gender` attr.
;   class  - matches the NPC's `class-situation` self-belief band.
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
  (record [k female] [k class-situation upper]  FM_MidClass_01.spawn)
  (record [k female] [k class-situation middle] FM_MidClass_02.spawn)
  (record [k female] [k class-situation lower]  FM_LowClass_01.spawn)
  (record [k female] any                        FM_LowClass_01.spawn)

  ; -- male --
  (record [k male]   [k class-situation upper]  Male_Medium_UpperClass_01.spawn)
  (record [k male]   [k class-situation middle] Male_Medium_MiddleClass_01.spawn)
  (record [k male]   [k class-situation lower]  Male_Medium_WorkingClass_01.spawn)
  (record [k male]   any                        Male_Medium_WorkingClass_01.spawn))
