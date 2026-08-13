; ----------------------------------------------------------------------------
; rehabilitation (Phase 9.3, B4 pressure model). A DISREPUTABLE NPC feels a
; second, distinct pull toward church - not piety but the wish to restore
; standing. A SECOND worship DRIVE: it mints the same abstract {@self worship}
; drive goal want_worship (worship_think.hs) proposes, on a shorter 15-day itch;
; the two utility sources SUM on that one goal, so a disreputable devout man is
; drawn hardest, and BOTH pressures relieve on one act (both ramp with
; days-since-last worship, which the worship act resets). The shared worship_go
; (route) + worship_act (perform) rungs do the routing / performing - none here.
;
; The rehabilitation PAYOFF needs no wiring: the worship acts feed classify_piety
; -> piety -> classify_respectability, so the more a disreputable man attends, the
; more respectable - the slow multi-year climb, driven by this pull.
;
; Why disreputable not scandalous: the scandalous is already ostracised; a church
; visit cannot lift them in one pass. The disreputable can rehabilitate.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think rehabilitation
  (cooldown 15 d)
  (role @self (old_human @self)
              {@self repute [k disreputable]})   ; derive-maintained band - cached
  (when    (>= (days-since-last {@self worship /ever}) 15))
  (utility (min (* (days-since-last {@self worship /ever}) 2) 40))
  (effects       (begin-goal {@self worship}))
  (cease-effects (end-goal   {@self worship})))
