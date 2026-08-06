; ----------------------------------------------------------------------------
; goal_macros.hs - read an NPC's own goals through the unified belief path.
;
; A goal is a belief {@self goal {@self <action> <focus>}} whose TARGET is a
; nested CLAUSE (the action + its focus). The goal-read forms below read that nested
; clause via the `target` op (nested-clause pattern support in the engine), so a goal
; reads like any other belief. The read runs in @self's OWN mind (goals are self-
; authored; no telepathy).
;
; The goal read forms:
;   (goal  {@self <action> [<target>]}) - engine primitive, a first-position event
;       CLAUSE: requires the goal, binds a free clause-target ?var off it, and pins it
;       as the auto-/caused_by of sub-goals the rule mints.
;   (has-goal {@self <action> [<target>]}) - boolean read (use in when/if/and/or/effects).
;       A macro over (believes {@self goal {..}}) - defined in definitions/roles.hs.
;   (no-goal {@self <action> [<target>]}) - boolean negative, the (not ...) twin -
;       also a roles.hs macro.
;   (has-proposal {@self <action> [<target>]}) - engine primitive: reads a PENDING
;       (un-promoted) proposal - a pipeline node, NOT a belief, so no believes read
;       can see it.
; ----------------------------------------------------------------------------
