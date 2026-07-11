; ----------------------------------------------------------------------------
; worship - the churchgoing lane, B4 desire + case sub-goals (mirrors the drinking
; lane in crave_drink.hs).
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
;
; The {@self worship} act-belief - begun at commit, ended by (end-act) at completion - IS
; the episodic service memory (interval = the service). days-since-last reads it for the
; pressure; classify_piety reads it (any-tense) for the gist. Locationless like `drink`:
; the church co-presence comes from being AT the church (location), not from the belief.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; The DESIRE - SCHEDULED per Sunday (the sabbath). A churchgoer (some politeness) who has
; not been to a service in the last few days wants to attend TODAY; worshipping resets
; days-since, so it fires ONCE per Sunday and again the next - weekly churchgoing. (now-weekday)
; is 0 on Sunday, so (< (now-weekday) 1) is the sabbath test. A HIGH Sunday utility (x
; politeness) so churchgoing wins the day's motor and reliably routes the NPC to a church,
; instead of losing the pure pressure-vs-routine competition the weekday model always lost.
(npc-think want_worship
  (short-term-think)
 (role @self (grown @self))
  (when    (and (< (now-weekday) 1)
                (>= (days-since-last @self worship) 3)
                (>= (attr @self politeness) 0.3)))
  (utility (* (attr @self politeness) 80))
  (cont-fire-effects (excl-goal {@self worship})))

; CASE B - not at a church, but knows one: head to it. Inherits the worship drive.
(npc-think worship_go
  (short-term-think)
  (goal    {@self worship})
  (role @self (grown @self))
  (role ?church [k building church] (select (score (near @self ?church)) (policy roulette)))
  (when    (not (is-a (current-building @self) [k building church])))
  (cont-fire-effects (go-into ?church)))

; CASE C - not at a church and knows none: search for one (find_building.hs runs it).
(npc-think worship_find
  (short-term-think)
  (goal    {@self worship})
  (fatigue-timeout 90)                                 ; ~90 min of searching a day, then rest
  (role @self (grown @self))
  (no-role [k building church])
  (when    (not (is-a (current-building @self) [k building church])))
  (cont-fire-effects (excl-goal {@self find_building [k building church]})))

; The service (case A): at a church {@self worship} is the leaf and promotes here. The
; act-belief IS the service memory; ending it closes its interval to the ~90-min service.
(npc-act worship_act
  (when (believes {@self worship}))
  (duration 90)
  (effects (end-act {@self worship})))
; go_act (the shared travel act) lives in npc-act/go.hs.
