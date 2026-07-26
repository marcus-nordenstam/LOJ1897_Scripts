; ----------------------------------------------------------------------------
; find_building (npc-think lane) - the venue-discovery search. A seek rule maintains
; {@self find_building [k building <kind>] ?region} as a bodyless TASK (promoted + run); these two
; thinks decompose the running search: cover the region one hop at a time, or conclude it failed.
;
; The running search is matched with a CACHED self-gate (role @self (believes {@self find_building
; ?sought ?region})) - binds ?sought (the sought kind) + ?region (the region to cover) off the task
; belief; a seeker not searching pays nothing.
;
; find_survey hops to the CLOSEST unobserved structure in the region. (latch-eval (bind
; (closest-unobserved [k structure] ?region) ?dest)) LATCHES ?dest when it first binds and holds it
; while the go act walks (no re-roll mid-route); the sibling (not (at-threshold @self ?dest))
; re-evaluates and falls on ARRIVAL, so the (when) fails - which RESETS the latch, and the next cycle
; re-binds the next unobserved structure. go_to_threshold front-parks at ?dest's face, where
; perception teaches the building AND its kind - so if it is the sought venue the seeker's own
; (no-role [k building <kind>]) flips and the search ends naturally (success is not stamped here). The
; hop /causes the find task, so it competes at the task's inherited drive. Searching STRUCTURES, not
; the sought kind, keeps it non-telepathic: perception reveals which structure is a church.
;
; find_exhausted fires once every structure in the region is observed (closest-unobserved fails):
; the sought kind was not found, so conclude the task /fail (the seeker gives up - no such venue).
; ----------------------------------------------------------------------------

(npc-think find_survey
  (role @self (believes {@self find_building ?sought ?region}))
  (when (and (latch-eval (bind (closest-unobserved [k structure] ?region) ?dest))
             (bind (observed ?dest) ?observed)
             (not (observed ?dest))))
  (effects ;(debug-print "SURVEY @self dest=?dest")
           (maintain-proposal {@self go_to_threshold ?dest} /cause {@self find_building ?sought ?region})))

(npc-think find_exhausted
  (role @self (believes {@self find_building ?sought ?region}))
  (when (not (is-entity (closest-unobserved [k structure] ?region))))
  (effects (set-outcome {@self find_building ?sought ?region} fail)))
