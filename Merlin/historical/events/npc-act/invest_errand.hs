; ----------------------------------------------------------------------------
; invest_errand - the npc-ACT half of the investment split (Item 5).
;
; The decision (business.hs `investment`) minted {@self goal {@self back
; <candidate>}} on the BACKER. He calls on the candidate and the backing is sealed
; there: {<candidate> backed_by @self}. The candidate is the goal focus; the backer
; navigates to the home he ALREADY KNOWS - his OWN belief {?candidate home ?h},
; mirrored when they became acquainted (no telepathy). An unknown address fails the
; bind and the call cannot be made (directory lookup is future work).
;
;   invest_go     : hold the goal, not at the candidate's home -> travel act.
;   invest_dwell  : hold the goal, AT the candidate's home -> a short dwell.
;   invest_commit : completion (completion-only) - records {<candidate> backed_by @self}
;                   (subject = the candidate via goal-focus, target = the backer)
;                   + clears the goal.
; ----------------------------------------------------------------------------

(hsim-event invest_go
  (intra-day)
  (nl   "@self calls on a promising man")
  (let ((?candidate (goal-focus back)))
    (when (and (has-goal back)
               (bind {?candidate home ?cand_home})
               (not (self-at ?cand_home))))
    (utility 60)
    (effects (go @self ?cand_home))))

(hsim-event invest_dwell
  (intra-day)
  (nl   "@self discusses a venture")
  (let ((?candidate (goal-focus back)))
    (when (and (has-goal back)
               (bind {?candidate home ?cand_home})
               (self-at ?cand_home)))
    (utility 60)
    (effects (act invest_commit 45))))

(hsim-event invest_commit
  (schedule (completion-only))
  (nl   "@self backs a venture")
  (effects
    (begin-belief (goal-focus back) backed_by @self)
    (clear-goal @self back)
    (log _investment @self)))
