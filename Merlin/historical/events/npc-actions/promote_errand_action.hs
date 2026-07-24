; ----------------------------------------------------------------------------
; promote_errand (npc-action) - the ACT half of the employer-side promotion split.
;
; The decision (employment.hs `promotion`) minted {@self goal {@self promote_staff
; <worker>}} on the BOSS. He goes to the workplace and advances the worker's grade
; there. The worker is the goal focus. The go/dwell think half lives in
; npc-think/promote_errand.hs; this file holds the completion commit.
; ----------------------------------------------------------------------------

(npc-action {@self promote_staff ?worker}
  (duration 45)
  (effects
    (promote /worker ?worker)
    (set-outcome {@self promote_staff} succ)))
