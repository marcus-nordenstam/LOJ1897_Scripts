; ----------------------------------------------------------------------------
; partner_errand - the npc-THINK half of the business-partnership split (approach).
; The clerk holds {@self partner <articles>}: travel to the firm's premises, then
; dwell there to settle the terms.
; ----------------------------------------------------------------------------

(npc-think partner_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self partner})
  (when (and (articles-building (goal-focus partner) ?venue)
             (not (in-building ?venue))))
  (utility 85)
  (effects       (begin-goal {@self enter ?venue}))
  (cease-effects (end-goal   {@self enter ?venue})))

(npc-think partner_dwell
  (short-term-think)
  (goal {@self partner})
  (when (and (articles-building (goal-focus partner) ?venue)
             (in-building ?venue)))
  (utility 85)
  (cont-fire-effects (begin-goal {@self partner})))
