; ----------------------------------------------------------------------------
; goal_macros.hs - read an NPC's own goals through the unified belief path.
;
; A goal is a belief {@self goal {@self <action> <focus>}} whose TARGET is a
; nested CLAUSE (the action + its focus). This macro reads that nested clause via
; the `target` op (nested-clause pattern support in the engine), so a goal reads
; like any other belief. The read runs in @self's OWN mind (goals are self-
; authored; no telepathy).
;
;   (goal-focus ?action) -> the focus entity of that goal (@fail if none).
;
; The goal REQUIREMENT / read forms are engine primitives now, not macros:
;   (goal  {@self <action> [<target>]}) - a first-position event CLAUSE: requires the
;       goal, binds a free clause-target ?var off it, and pins it as the auto-/cause
;       of sub-goals the rule mints.
;   (goal? {@self <action> [<target>]}) - boolean read (use in when/if/and/or/effects).
;   (no-goal {@self <action> [<target>]}) - boolean negative (symmetric with no-role).
; The old (has-goal ...) / (has-goal-on ...) macros are retired in favour of these.
; ----------------------------------------------------------------------------

(define-macro goal-focus (?action)
  (target {@self goal {@self ?action ?}}))
