; The (goal ...) gate's whole-pattern capture: `:?g` binds the matched GOAL-BELIEF
; symbol (the same general `{pattern}:?var` mechanism believes/bind/(task ...) use),
; and the gate PUSH-arms this rule off the goal write - no matching goal, no
; activation attempt.
(think probe_goal_cap
  (cooldown 1 m try-once)
  (goal {@self probe_hunt ?prey11}:?probe_hunt)
  (effects (debug-print "PROBE_GOAL_CAP goal=?probe_hunt prey=?prey11")))
