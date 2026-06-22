; ----------------------------------------------------------------------------
; partner_errand - the npc-ACT half of the business-partnership split (Item 5).
;
; The decision (business.hs `business_partnership`) minted {@self goal {@self
; partner <principal_articles>}}. The clerk goes to the firm's premises and is
; bought in there - the partnership documents (the clue trail) + the co-presence a
; witness would see, instead of a faceless world edit. The firm's articles are the
; goal focus, so the premises are (articles-building (goal-focus partner)).
;
;   partner_go     : hold the goal, not at the firm -> travel act to its premises.
;   partner_dwell  : hold the goal, AT the firm -> a dwell (settling the terms).
;   partner_commit : completion (completion-only) - leaves his salaried post, is added
;                    as co-owner + installed as proprietor (org_head), clears goal.
; ----------------------------------------------------------------------------

(hsim-event partner_go
  (intra-day)
  (nl   "@self sets out to settle a partnership")
  (let ((?venue (articles-building (goal-focus partner))))
    (when (and (has-goal partner)
               (not (at-place ?venue))))
    (utility 85)
    (effects (go @self ?venue))))

(hsim-event partner_dwell
  (intra-day)
  (nl   "@self settles into the firm")
  (let ((?venue (articles-building (goal-focus partner))))
    (when (and (has-goal partner)
               (at-place ?venue)))
    (utility 85)
    (effects (act partner_commit 90))))

(hsim-event partner_commit
  (schedule (completion-only))
  (nl   "@self is taken into partnership")
  (effects
    (fire :worker @self)
    (add-co-owner :articles (goal-focus partner) :owner @self)
    (hire :articles (goal-focus partner) :worker @self :role proprietor :level org_head)
    (clear-goal @self partner)
    (log _business_partnership @self)))
