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

(npc-act partner_act
  (when (believes {@self partner}))
  (duration 90)
  (act-effects
    ; bind the firm's articles to a plain ?var (hire-seq needs it as a {pattern} subject).
    (bind (goal-focus partner) ?art)
    (fire /worker @self)
    (add-co-owner /articles ?art /owner @self)
    (hire-seq ?art [k job proprietor] [k org_head])
    (end-act {@self partner})
    (end-goal {@self partner})))
