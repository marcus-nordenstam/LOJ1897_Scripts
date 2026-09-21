; ----------------------------------------------------------------------------
; put ?item ?dest - set the held item down at ?dest, a space or a surface. The task
; CLAIMS the cell the thing will rest on - polling the grid until it answers one - and
; hands it to the act; the claim is the rung's and lapses with it. The outcome try
; concludes once the put succeeded /caused_by this task.
;
; UNPRESENTED ONLY, for as long as PUT is: the presented branch reaches the gripping hand
; to the cell and opens with UNGRASP (action_unification_plan.md 5.9).
; ----------------------------------------------------------------------------

(npc-task {@self put ?item ?dest}:?put-rel
  (tar @excl [k object] @object)
  (and
    (try
      (when (unpresented-lod))
      (when (substantial (spatial ?item gripped-by)))
      (when (poll (rest-cell ?dest ?item): ?cell))
      (effects (maintain-proposal {@self PUT ?item ?cell})))
    (try
      (when {@self /succ PUT ?item ? /caused_by ?put-rel})
      (effects (set-outcome ?put-rel /succ)))))
