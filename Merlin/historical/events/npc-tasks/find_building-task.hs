; ----------------------------------------------------------------------------
; find_building - the venue-discovery search. A seek rule maintains
; {@self find_building [k building <kind>] ?region} as a bodyless TASK; these two tries
; decompose the running search: cover the region one hop at a time, or conclude it failed.
; The head binds ?sought (the sought kind) + ?region (the region) off the matched task,
; and captures the task belief :?find_task-rel so the outcome try can conclude it.
;
;   find_survey hops to the CLOSEST unobserved structure. (latch-eval (closest-unobserved
;     ...): ?dest) LATCHES ?dest while the go act walks; the sibling (not (observed ?dest))
;     falls on ARRIVAL, resetting the latch so the next cycle re-binds the next structure.
;     go_to_threshold front-parks at ?dest's face, where perception teaches the building
;     and its kind - so the sought venue ends the search naturally (success is not stamped
;     here). Searching STRUCTURES, not the sought kind, keeps it non-telepathic.
;   find_exhausted fires once every structure is observed (closest-unobserved fails): the
;     sought kind was not found, so conclude /fail (no such venue).
;
; and (not stable-or): the guards are COMPLEMENTARY on closest-unobserved existence, so
; exactly one try is ever live - exclusivity is inherent in the gates.
; ----------------------------------------------------------------------------

(npc-task {@self find_building ?sought ?region}:?find_task-rel
  (tar ?)
  (aux ?)
  (and
    (try
      (when (and (latch-eval (closest-unobserved [k structure] ?region): ?dest)
                 (observed ?dest): ?observed
                 (not (observed ?dest))))
      (effects (maintain-proposal {@self GO_TO_THRESHOLD ?dest})))
    (try
      (when (not (closest-unobserved [k structure] ?region)))
      (effects (set-outcome ?find_task-rel fail)))))
