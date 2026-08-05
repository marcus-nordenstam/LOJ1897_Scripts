; ----------------------------------------------------------------------------
; The DRINKING lane - B4 desire + case sub-goals (hierarchical goals).
;
; ONE desire computes the pressure ONCE; the case rules just read the drink goal and
; maintain the appropriate sub-goal, which INHERITS the drink drive (mint_goal /cause
; inheritance) and, as the live leaf, out-competes its parent (leaf-only promotion):
;
;   want_drink  (desire): pressure-gated (drink-due), utility = drink-drive. Holds
;                {@self drink} while thirsty; auto-retracts when the pressure lapses.
;   AT a pub   (case A):  drink_at_pub proposes {@self drink} - the leaf label promotes
;                to drink_act (drink.hs); the bare goal never self-promotes.
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

; TERMINAL step (act_body_purification): the drink act is PROPOSED, precondition-guarded, not
; promoted by the bare {@self drink} goal. Because `drink` is a proposed label, that goal drops out
; of the competition (it still persists + drives the routing sub-goals below) - so the drink act
; promotes ONLY here, ONLY at a pub (can-drink). The off-pub "street-drink" hole is closed by
; construction.
(npc-think drink_at_pub
  (goal    {@self drink})
  (role @self (grown @self))
  (when    (can-drink @self))
  (utility (drink-drive @self))
  (effects (maintain-proposal {@self drink})))

; CASE B - not at a pub, but knows one: head to it via the generic enter chain (§5.11). A
; maintenance event: it roulettes a pub ONCE and mints {@self enter ?pub}, then STICKS with that
; pub (no re-roulette while walking); on arrival (in-building ?pub) the (when) drops and
; cease-effects end the enter-goal. The enter chain steps
; the drinker INSIDE the pub, so can-drink (current-building is-a pub) then holds and drink_act
; promotes.
(npc-think drink_go
  (goal    {@self drink})
  (role @self (grown @self))
  (role ?pub [k building pub] (select (score (near @self ?pub)) (policy roulette)))
  (when    (not (in-building ?pub)))
  (effects (maintain-proposal {@self enter ?pub})))

; CASE C - not at a pub and knows none: search for one (find_building.hs runs it). A maintenance
; event: it mints the standing find goal and holds it while the search runs; the moment a pub is
; learned the (no-role) gate flips (or arrival makes can-drink hold), the find goal ends, and the
; go rung takes over.
(npc-think drink_find
  (goal    {@self drink})
  (role @self (grown @self))
  (no-role [k building pub])
  ; Search while no pub is known and the region is not yet proven publess (find_building's /fail
  ; fires only once the whole region is covered without finding one).
  (when    (and (not (can-drink @self))
                (not (did-fail {@self find_building [k building pub] /past}))))
  (effects (maintain-proposal {@self find_building [k building pub] (current-region @self)})))
