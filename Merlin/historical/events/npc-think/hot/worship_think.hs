; ----------------------------------------------------------------------------
; worship (npc-think lane) - the churchgoing lane, B4 desire + case sub-goals
; (mirrors the drinking lane in crave_drink.hs). The service act lives in
; npc-act/worship.hs.
;
; ONE desire computes the pressure ONCE; the case rules read the worship goal and
; maintain the appropriate sub-goal, which INHERITS the worship drive (auto-/caused_by off
; the (goal ...) clause) and, as the live leaf, out-competes its parent (leaf-only):
;
;   want_worship (desire): PRESSURE = days since the last service, x politeness (respect
;     for convention), CAPPED as a LEISURE act (max ~40, below work / meals / sleep). It
;     rises daily and collapses the moment the NPC worships, so a devout man is drawn back
;     ~weekly while a secular one never clears a routine act. Holds {@self worship}.
;   AT a church (case A): {@self worship} has no active sub-goal, so it is the leaf and
;     promotes straight to worship_act (the service). No rule needed.
;   know a church (case B): worship_go holds {@self go ?church}.
;   know none  (case C): worship_find holds {@self find_building [k church]}.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")
(include "../../../macros/intensity_macros.hs")

; TERMINAL step (act_body_purification): the service is now PROPOSED, guarded by being IN a church.
; Because `worship` is a proposed label the {@self worship} desire drops out of the auction (it
; still persists + drives worship_go/find), so worship promotes ONLY here, ONLY at a church - no
; off-church fall-through.
(npc-think worship_at_church
  (goal    {@self worship})
  (role @self (grown @self))
  (when    (is-a (current-building @self) [k building church]))
  (effects (maintain-proposal {@self worship})))

; CASE B - not at a church, but knows one: head to it. Inherits the worship drive. A
; MAINTENANCE rung (§5.11): roulette a church ONCE, hold {@self enter ?church} (the
; generic enter chain routes the actual travel), and cease it on arrival (in-building
; ?church). The rouletted ?church is stashed at fire, so the hold + cease operate on the
; SAME church (no re-roulette while walking).
(npc-think worship_go
  (goal    {@self worship})
  (role @self (grown @self))
  (role ?church [k building church] (select (score (near @self ?church)) (policy roulette)))
  (when    (not (in-building @self ?church)))
  (effects (debug-print "TRACE-WORSHIPGO church=?church")
           (maintain-proposal {@self enter ?church})))

; CASE C - not at a church and knows none: search for one (find_building.hs runs it).
(npc-think worship_find
  (goal    {@self worship})
  (role @self (grown @self))
  (no-role [k building church])
  (when    (and (not (is-a (current-building @self) [k building church]))
                (not (did-fail {@self find_building [k building church] /past}))))
  (effects (debug-print "WSEEK @self")
           (maintain-proposal {@self find_building [k building church] (current-region @self)})))
