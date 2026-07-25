; ----------------------------------------------------------------------------
; partner_errand - the npc-ACT half of the business-partnership split (Item 5).
;
; The decision (business.hs `business_partnership`) minted {@self goal {@self
; partner <principal_articles>}}. The clerk goes to the firm's premises and is
; bought in there - the partnership documents (the clue trail) + the co-presence a
; witness would see, instead of a faceless world edit. The firm's articles are the
; act focus (?art, bound in the pattern); the premises are its articles-building.
;
;   partner_go     : hold the goal, not at the firm -> travel act to its premises.
;   partner_dwell  : hold the goal, AT the firm -> a dwell (settling the terms).
;   partner_commit : completion (completion-only) - leaves his salaried post, is added
;                    as co-owner + installed as proprietor (org_head), clears goal.
; ----------------------------------------------------------------------------

(npc-action {@self partner ?art}
  (duration 90)
  (effects
    (fire /worker @self)
    (add-co-owner /articles ?art /owner @self)
    (hire-seq ?art [k job proprietor] [k senior])
    (set-outcome {@self partner} succ)))
