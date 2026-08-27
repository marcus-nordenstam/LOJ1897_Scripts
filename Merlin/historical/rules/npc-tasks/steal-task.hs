; ----------------------------------------------------------------------------
; steal - NO-OP declaration stub. The theft crime is currently DRIVEN by the
; burgle lane (burgle_think.hs) off a {@self steal} goal, and its record
; ({@self steal ?victim}) is minted there; this npc-task exists only to SELF-
; DECLARE the `steal` label + its crime metadata (construed_act / theme / facets)
; so the ontology/Tasks.mon row can retire. To be fleshed out into the real
; theft task later. The (try) never fires (nothing promotes {@self steal} as a
; running task - burgle works off the goal), so this is a pure declaration.
; ----------------------------------------------------------------------------

(npc-task {@self steal ?victim}:?steal-rel
  (tar human)
  (construed_act appropriation_act wrong_act) (theme thief_to)
  (facets reportable_crime blackmailable)
  (try
    (role @self)
    (when (chance 0))
    (effects (set-outcome ?steal-rel succ))))
