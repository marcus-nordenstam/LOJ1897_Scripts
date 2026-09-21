; ----------------------------------------------------------------------------
; MAKE-DONE-STACK ?working-stack ?where - start a second pile beside the one being
; worked, for the papers already dealt with.
;
; PORTED from the C++ handler, whose run_func is here in full: mint an empty stack
; entity at ?where, perceive both piles, and write the working -> done link onto the
; actor's own private blackboard, which is where a stack-reading round keeps its
; scratch. Nothing about it needed the scene - the handler built a t_env_entity_config
; by hand because it had no rule-func to call, and (create-entity ..) is that func.
;
; TWO OBSERVES, not one. A pile he minted but never looked at is a pile he does not
; know he has, and the bb link is only useful if both ends name things he can reason
; about - which is what the mental symbols an (observe ..) returns are.
; ----------------------------------------------------------------------------

(npc-action {@self MAKE-DONE-STACK ?working-stack ?where}:?mds
  (motor eyes legs)
  (obs)
  (tar @excl)
  (duration 0)
  (presentation
    (preroll 0.0) (in 0.0) (out 0.0))

  (init
    (if (or (unsubstantial ?working-stack) (unsubstantial ?where))
        (then (set-outcome ?mds /fail))))

  (effects
    (check (spatial ?working-stack co-located @self /env))
    (create-entity [k stack] ?where): ?done
    (cond
      (case (substantial ?done)
        (observe ?done): ?known-done
        (observe ?working-stack): ?known-working
        (bb-write ?known-working done-stack ?known-done)
        (set-outcome ?mds /succ))
      (else (set-outcome ?mds /fail)))))
