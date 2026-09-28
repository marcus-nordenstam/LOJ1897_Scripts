; ----------------------------------------------------------------------------
; put ?item ?dest - set the held item down at ?dest, a space or a surface. The task
; CLAIMS the spot the thing will rest on - polling the search until it answers one - and
; hands it to the act; the claim is the rung's and lapses with it. The outcome try
; concludes once the put succeeded /caused_by this task.
;
; UNPRESENTED ONLY, for as long as PUT is: the presented branch reaches the gripping hand
; to the spot and opens with UNGRASP (action_unification_plan.md 5.9).
; ----------------------------------------------------------------------------

(npc-task {@self put ?item ?dest}:?put
  (tar @excl [k object] @object)
  (and
    (try
      (when (unpresented-lod))
      (when (substantial (spatial ?item gripped-by)))
      (when (poll (rest-spot ?dest ?item): ?spot))
      (effects (maintain-proposal {@self PUT ?item ?spot})))
    (try
      (when {@self /succ PUT ?item ? /caused_by ?put})
      (effects (set-outcome ?put /succ)))))
