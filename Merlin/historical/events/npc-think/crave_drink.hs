; ----------------------------------------------------------------------------
; The DRINKING lane - B4 desire + case sub-goals (hierarchical goals).
;
; ONE desire computes the pressure ONCE; the case rules just read the drink goal and
; maintain the appropriate sub-goal, which INHERITS the drink drive (mint_goal /cause
; inheritance) and, as the live leaf, out-competes its parent (leaf-only promotion):
;
;   want_drink  (desire): pressure-gated (drink-due), utility = drink-drive. Holds
;                {@self drink} while thirsty; auto-retracts when the pressure lapses.
;   AT a pub   (case A):  {@self drink} has no active sub-goal, so it is the leaf and
;                promotes straight to drink_act (drink.hs). No rule needed.
;   know a pub (case B):  drink_go holds {@self go ?pub} /cause the drink goal.
;   know none  (case C):  drink_find holds {@self find_building [k pub]} /cause it.
;
; The go / find sub-goals carry the inherited drive and, being the live leaves, win the
; motor; the drink goal itself only promotes once no sub-goal is active (i.e. at a pub).
; The cases are mutually exclusive (at-pub vs role ?pub vs no-role), so exactly one path
; is live at a time.
;
; Already-dependent NPCs are excluded here (relapse.hs casts them - a second drink source).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; The DESIRE. The ONLY place the pressure is computed.
(npc-think want_drink
  (short-term-think)
  (roles (role @self (grown @self)))
  (when    (drink-due @self))
  (utility (drink-drive @self))
  (cont-fire-effects (excl-goal {@self drink})))

; CASE B - not at a pub, but knows one: head to it. The (goal ...) clause pins the drink
; goal as this rule's parent, so the go sub-goal inherits the drink drive and auto-links
; its /cause - no hand-written /cause, no re-checked pressure.
(npc-think drink_go
  (short-term-think)
  (goal    {@self drink})
  (roles
    (role @self (grown @self))
    (role ?pub [k building pub] (prefer (near @self ?pub)) (policy weighted)))
  (when    (not (can-drink @self)))
  (cont-fire-effects (excl-goal {@self go ?pub})))

; CASE C - not at a pub and knows none: search for one (find_building.hs runs it).
(npc-think drink_find
  (short-term-think)
  (goal    {@self drink})
  (fatigue-timeout 90)                                 ; ~90 min of searching a day, then rest
  (roles
    (role @self (grown @self))
    (no-role [k building pub]))
  (when    (not (can-drink @self)))
  (cont-fire-effects (excl-goal {@self find_building [k building pub]})))
