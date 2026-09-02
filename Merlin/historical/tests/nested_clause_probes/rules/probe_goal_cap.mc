; The (goal ...) gate's whole-pattern capture: `:?g` binds the matched GOAL-BELIEF
; symbol (the same general `{pattern}:?var` mechanism believes/bind/(task ...) use),
; and the gate PUSH-arms this rule off the goal write - no matching goal, no
; activation attempt.
(npc-think probe_goal_cap
  (cooldown 1 m)
  (goal {@self probe_hunt ?prey11}:?g11)
  (effects (debug-print "PROBE_GOAL_CAP goal=?g11 prey=?prey11")))
