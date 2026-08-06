Nested-clause role-matching probe suite (docs/plans/nested_clause_role_matching_plan.md §9).

Run the events/ dir alone against the 1yr cfg:
  hsim.exe --cfg .../definitions/historical_1yr.hs --events .../tests/nested_clause_probes/events --out probes.msb

Expected: PROBE_MINT, PROBE_WHEN_EXISTS, PROBE_TENSE_OK, PROBE_BIND, PROBE_ROLE,
PROBE_RESIDUAL, PROBE_JOIN, PROBE_GOAL_CAP each fire once per NPC (49 at 50-pop);
PROBE_CAUSE fires with bond=<a real belief symbol> ((bind (begin-belief ..) ?b) +
/caused_by ?b); PROBE_GOAL_CAP prints goal=<the matched goal-belief symbol> (the
whole-pattern {..}:?var capture on the (goal ...) gate). Zero ERROR lines.

parse_errors/ holds one-event files that must each ABORT the load with a named
message (run each file alone as its own --events dir): inner /their-mind, inner
(fan-out ?x), clause nesting deeper than k_max_clause_depth, and declaring BOTH
(goal ...) and (task ...) (mutually exclusive gates). bad_inner_expr.hs is the
exception: it must LOAD (an inner op-expr in an enumerated role routes to the
residual bucket and evaluates live; only the alpha cache rejects it).
