; ----------------------------------------------------------------------------
; rehabilitation (Phase 9.3, B4 pressure model). A DISREPUTABLE NPC feels a
; second, distinct pull toward church - not piety but the wish to restore
; standing. It is a SECOND utility source on the very same {@self worship
; <church>} act-goal that feel_devout (worship.hs) proposes: the two sources
; SUM, so a disreputable devout man is drawn hardest of all, and BOTH pressures
; are relieved by one act because both ramp with `days-since-last worship`, which
; the worship act resets. No per-pressure bookkeeping, no reset the act must know.
;
; The rehabilitation PAYOFF needs no wiring here: the worship acts feed
; classify_piety (any-tense count) -> piety -> classify_respectability, so the
; more a disreputable man attends, the more pious, the more respectable - the
; slow multi-year climb, driven by this pull.
;
; Why disreputable not scandalous: the scandalous is already ostracised; a
; church visit cannot lift them in one pass. The disreputable can rehabilitate.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-think rehabilitation
  (short-term-think)

  (roles
    (role @self (old_human @self))
    ; The nearest church the NPC KNOWS (role-cast; no known church -> no fire).
    (role ?venue [k building church] (prefer (near @self ?venue)) (policy weighted)))

  ;; A disreputable adult, once a service is ~due. Shares feel_devout's
  ;; days-since-worship gate/ramp so worshipping resets this pressure too.
  (when (and (= (situation @self repute) [k disreputable])
             (>= (days-since-last @self worship) 15)))

  ;; Disrepute-driven pull: ramps with days-since-worship, capped as a leisure-
  ;; level source (well below work / meals / sleep). It STACKS on feel_devout's
  ;; source (utility summed at act-selection); on its own it draws even a secular
  ;; disreputable man to church.
  (utility (min (* (days-since-last @self worship) 2) 40))

  ;; The same churchgoing proposal feel_devout makes (shared macro) - both thinks
  ;; stack their utility on the one {@self worship <church>} act-goal.
  (effects (propose-venue-act ?venue worship)))
