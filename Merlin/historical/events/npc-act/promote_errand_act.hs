; ----------------------------------------------------------------------------
; promote_errand (npc-act) - the ACT half of the employer-side promotion split.
;
; The decision (employment.hs `promotion`) minted {@self goal {@self promote_staff
; <worker>}} on the BOSS. He goes to the workplace and advances the worker's grade
; there. The worker is the goal focus. The go/dwell think half lives in
; npc-think/promote_errand.hs; this file holds the completion commit.
; ----------------------------------------------------------------------------

(npc-act promote_staff_act
  (when (believes {@self promote_staff}))
  (duration 45)
  (act-effects
    (promote /worker (goal-focus promote_staff))
    (end-act {@self promote_staff})
    (end-goal {@self promote_staff})))
