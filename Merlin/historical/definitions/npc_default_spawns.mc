; ----------------------------------------------------------------------------
; npc_default_spawns.hs - default character appearance for hsim-created NPCs.
;
; hsim-created NPCs (the murder victim / body, townsfolk, anyone the player
; walks up to) carry NO authored presentation. This table picks the default
; character .spawn each one renders as, by gender + class-situation.
;
; Read PLAYER-side by ProximityPresenter via the shared hsim s-expr parser
; (parse_sexpr_file). The .spawn files are GrymEngine content assets, so the
; selection lives in the Player, not Merlin - this file is just the data.
;
; Each rule:
;   (spawn (gender <female|male>) (class <upper|middle|lower>) (file "<name>.spawn"))
;
;   - gender  matches the NPC's `gender` attr.
;   - class   matches the NPC's `class-situation` attr (upper / middle / lower).
;   - Any omitted filter is a WILDCARD.
;   - Rules are tried top-to-bottom; the FIRST whose every present filter matches
;     wins - so list specific rules before the per-gender catch-alls.
;   - file names resolve against the project Content/Spawn directory.
;
; (Age / role refinement can be added later as extra filters, e.g.
;  (role policeman); unknown filters are ignored, so adding them is additive.)
; ----------------------------------------------------------------------------

; -- female (only FM_LowClass / FM_MidClass spawns exist; upper borrows MidClass) --
(spawn (gender female) (class upper)  (file "FM_MidClass_01.spawn"))
(spawn (gender female) (class middle) (file "FM_MidClass_02.spawn"))
(spawn (gender female) (class lower)  (file "FM_LowClass_01.spawn"))
(spawn (gender female)                (file "FM_LowClass_01.spawn"))

; -- male --
(spawn (gender male)   (class upper)  (file "Male_Medium_UpperClass_01.spawn"))
(spawn (gender male)   (class middle) (file "Male_Medium_MiddleClass_01.spawn"))
(spawn (gender male)   (class lower)  (file "Male_Medium_WorkingClass_01.spawn"))
(spawn (gender male)                  (file "Male_Medium_WorkingClass_01.spawn"))
