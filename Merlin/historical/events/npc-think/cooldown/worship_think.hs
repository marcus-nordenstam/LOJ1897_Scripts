; ----------------------------------------------------------------------------
; worship (npc-think lane) - the churchgoing lane, B4 desire + case sub-goals
; (mirrors the drinking lane in crave_drink.hs). The service act lives in
; npc-act/worship.hs.
;
; ONE desire computes the pressure ONCE; the case rules read the worship goal and
; maintain the appropriate sub-goal, which INHERITS the worship drive (auto-/cause off
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

; The DESIRE. A churchgoer (some politeness) who has not been to a service since the
; last representative day wants to attend. hsim simulates ONE representative day per
; monthly window, so this is the finest churchgoing cadence the pre-sim can carry - a
; weekday gate (e.g. Sunday-only) would fire only on the ~1 window a year whose
; representative day happens to land on that weekday, never converging. Worshipping
; resets days-since, so it re-arms each window. A HIGH utility (x politeness) so
; churchgoing wins the representative day's motor when the NPC is off work and reliably
; routes them to a church, instead of losing the pure pressure-vs-routine competition.
(npc-think want_worship
  ; Rhythmic drive: a 3-day cooldown re-checks the urge; the (days-since) + politeness
  ; fire-gate holds the standing worship desire while due. The MINTER owns un-minting:
  ; once worship_act resets days-since-last the (when) drops, ending
  ; {@self worship}. The act never ends the goal.
  (cooldown 3 d)
  (role @self (grown @self))
  (when    (and (>= (days-since-last @self worship) 3)
                (>= (attr @self politeness) 0.3)))
  (utility (recency-ramp worship 3 21 50))
  (effects       (debug-print "WANTWORSHIP @self")
                 (begin-goal {@self worship}))
  (cease-effects (end-goal   {@self worship})))
