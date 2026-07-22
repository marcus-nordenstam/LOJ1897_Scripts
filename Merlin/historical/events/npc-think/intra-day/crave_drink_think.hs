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

(include "../../../definitions/roles.hs")

; The DESIRE, and the MAINTENANCE event that owns the drink goal end to end. A 3-day cooldown
; re-checks the urge; the (days-since) gate holds the standing drink desire while genuinely due
; (also catching a cross-source drink via the relapse lane); the drink-drive utility competes it.
; The MINTER owns un-minting: once drink_act completes, days-since-last resets, the (when) drops,
; and the falling edge ends {@self drink}. The act itself never ends the goal.
(npc-think want_drink
  (schedule cooldown 3 d)
  (if-blocked hold)
  (role @self (grown @self)
              (not (believes {@self craving [k alcohol]})))   ; dependents use the relapse lane
  (when          (>= (days-since-last @self drink) 3))
  (utility       (drink-drive @self))
  (effects       (begin-goal {@self drink}))
  (cease-effects (end-goal   {@self drink})))

; TERMINAL step (act_body_purification): the drink act is now PROPOSED, precondition-guarded, not
; promoted by the bare {@self drink} goal. Because `drink` is a proposed label, that goal no longer
; competes (it still persists + drives the routing sub-goals below) - so the drink act promotes
; ONLY here, ONLY at a pub (can-drink). The off-pub "street-drink" hole is closed by construction.
; Reactive (schedule always): re-proposes each decision point while thirsty + at a pub.
(npc-think drink_at_pub
  (schedule on-commit)
  (if-blocked hold)
  (goal    {@self drink})
  (role @self (grown @self))
  (when    (can-drink @self))
  (utility (drink-drive @self))
  (effects (maintain-proposal {@self drink})))

; CASE B - not at a pub, but knows one: head to it via the generic enter chain (§5.11). A
; MAINTENANCE event: on the FIRST fire it roulettes a pub and mints {@self enter ?pub}, then
; settles into k_holding so it STICKS with that pub (no re-roulette while walking); on arrival
; (in-building ?pub) the (when) drops and cease-effects end the enter-goal. The enter chain steps
; the drinker INSIDE the pub, so can-drink (current-building is-a pub) then holds and drink_act
; promotes.
(npc-think drink_go
  (schedule on-commit)
  (if-blocked hold)
  (goal    {@self drink})
  (role @self (grown @self))
  (role ?pub [k building pub] (select (score (near @self ?pub)) (policy roulette)))
  (when    (not (in-building ?pub)))
  (effects       (begin-goal {@self enter ?pub}))
  (cease-effects (end-goal   {@self enter ?pub})))

; CASE C - not at a pub and knows none: search for one (find_building.hs runs it). A MAINTENANCE
; event: on the drink-goal commit it mints the standing find goal and holds it while the search
; runs; the moment a pub is learned the (no-role) gate flips (or arrival makes can-drink hold),
; the falling edge ends the find goal, and the go rung takes over.
(npc-think drink_find
  (schedule on-commit)
  (goal    {@self drink})
  (fatigue-timeout 90)                                 ; ~90 min of searching a day, then rest
  (role @self (grown @self))
  (no-role [k building pub])
  (when    (not (can-drink @self)))
  (effects       (begin-goal {@self find_building [k building pub]}))
  (cease-effects (end-goal   {@self find_building [k building pub]})))
