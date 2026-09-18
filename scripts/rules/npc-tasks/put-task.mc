; ----------------------------------------------------------------------------
; put ?item ?location - set the held item down. ONE rung now, not two: the hand is an
; argument to the act rather than part of its label, so the task reads which hand grips
; the item and hands it over. The outcome try concludes once the put succeeded
; /caused_by this task.
;
; UNPRESENTED ONLY, for as long as PUT is: the presented branch claims a cell on the
; destination surface, reaches the gripping hand to it and opens with UNGRASP, and the
; cell claim needs the env grid (action_unification_plan.md 5.9, section 10).
; ----------------------------------------------------------------------------

(npc-task {@self put ?item ?location}:?put-rel
  (tar @excl object)
  (and
    (try
      (when (unpresented-lod))
      (when (substantial (spatial ?item gripped-by)))
      (effects (maintain-proposal {@self PUT ?item ?location})))
    (try
      (when {@self /succ PUT ?item ?location /caused_by ?put-rel})
      (effects (set-outcome ?put-rel /succ)))))
