; ----------------------------------------------------------------------------
; The DRINKING lane - B4 desire + case sub-goals (hierarchical goals).
;
; ONE desire computes the pressure ONCE; the case rules just read the drink goal and
; maintain the appropriate sub-goal, which INHERITS the drink drive (mint_goal /caused_by
; inheritance) and, as the live leaf, out-competes its parent (leaf-only promotion):
;
;   want_drink  (desire): pressure-gated (drink-due), utility = drink-drive. Holds
;                {@self DRINK} while thirsty; auto-retracts when the pressure lapses.
;   AT a pub   (case A):  {@self DRINK} has no active sub-goal, so it is the leaf and
;                promotes straight to drink_act (drink.hs). No rule needed.
;   know a pub (case B):  drink_go holds {@self go ?pub} /caused_by the drink goal.
;   know none  (case C):  drink_find holds {@self find-building [k pub]} /caused_by it.
;
; The go / find sub-goals carry the inherited drive and, being the live leaves, win the
; motor; the drink goal itself only promotes once no sub-goal is active (i.e. at a pub).
; The cases are mutually exclusive (at-pub vs role ?pub vs no-role), so exactly one path
; is live at a time.
;
; Already-dependent NPCs are excluded here (relapse.hs casts them - a second drink source).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

; The DESIRE, and the MAINTENANCE rule that owns the drink goal end to end. A 3-day cooldown
; re-checks the urge; the (days-since) gate holds the standing drink desire while genuinely due
; (also catching a cross-source drink via the relapse lane); the drink-drive utility competes it.
; The MINTER owns un-minting: once drink_act completes, days-since-last resets, the (when) drops,
; and the falling edge ends {@self DRINK}. The act itself never ends the goal.
(npc-think want_drink
  (cooldown 3 d)
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
              -{@self craving [k alcohol]})   ; dependents use the relapse lane
  (when          (>= (days-since-last {@self DRINK /ever}) 3))
  (utility want (* 10 (drink-drive @self)))
  (effects       (begin-goal {@self DRINK}))
  (cease-effects (set-outcome {@self goal {@self DRINK}} /succ)))
