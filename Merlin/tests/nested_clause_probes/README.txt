Nested-clause role-matching probe suite (docs/plans/nested_clause_role_matching_plan.md §9).

Run the rules/ dir alone against the 1yr cfg:
  hsim.exe --cfg .../definitions/historical_1yr.hs --rulebook .../tests/nested_clause_probes/rules --out probes.msb

Expected: PROBE_MINT, PROBE_WHEN_EXISTS, PROBE_TENSE_OK, PROBE_BIND, PROBE_ROLE,
PROBE_RESIDUAL, PROBE_JOIN each fire once per NPC (49 at 50-pop);
PROBE_CAUSE fires with bond=<a real belief symbol> ((bind (begin-belief ..) ?b) +
/caused_by ?b); PROBE_GOAL_CAP and PROBE_GATEVAR fire TWICE per NPC (98) - probe_mint2
mints a second concurrent probe_hunt goal and the goal gate FANS OUT one activation
per matching goal, each printing its own bindings. Zero ERROR lines.

PROBE_GATEVAR is the gate-var-subject probe: the (goal ...) gate binds ?prey and a
(role @self ...) residual tests {?prey accomplice ?acc} - a belief whose SUBJECT is
that gate var. Residual placement seeds the (goal ...)/(task ...) gate vars, so the
subject is placeable (threaded live at the when-gate seam) instead of a hard load
error. acc binds to a real object (== prey, per the minted {?prey accomplice ?prey}).

parse_errors/ holds one-event files that must each ABORT the load with a named
message (run each file alone as its own --rulebook dir): inner (fan-out ?x),
clause nesting deeper than k_max_clause_depth, and declaring BOTH
(goal ...) and (task ...) (mutually exclusive gates). bad_inner_expr.hs is the
exception: it must LOAD (an inner op-expr in an enumerated role routes to the
residual bucket and evaluates live; only the alpha cache rejects it).
