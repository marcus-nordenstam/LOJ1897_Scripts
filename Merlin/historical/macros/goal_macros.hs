; ----------------------------------------------------------------------------
; goal_macros.hs - read an NPC's own goals through the unified belief path.
;
; A goal is a belief {@self goal {@self <action> <focus>}} whose TARGET is a
; nested CLAUSE (the action + its focus). These macros read that nested clause
; via believes / target (nested-clause pattern support in the engine), so a goal
; reads like any other belief - no bespoke C++ op. The read runs in @self's OWN
; mind (goals are self-authored; no telepathy).
;
;   (has-goal ?action)   -> does @self hold a goal whose action is ?action?
;   (goal-focus ?action) -> the focus entity of that goal (@fail if none).
;
; These REPLACE the old C++ (has-goal) / (goal-focus) ops. The npc-act errands
; keep their readable `(has-goal X)` / `(goal-focus X)` call sites unchanged.
; ----------------------------------------------------------------------------

(define-macro has-goal (?action)
  (believes {@self goal {@self ?action ?}}))

(define-macro goal-focus (?action)
  (target {@self goal {@self ?action ?}}))
