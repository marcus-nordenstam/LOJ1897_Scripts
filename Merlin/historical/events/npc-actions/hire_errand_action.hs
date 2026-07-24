; ----------------------------------------------------------------------------
; hire_errand - the npc-ACT half of the hiring split (Item 5, employee-side): the DUMB
; commit act (act_body_purification).
;
; The decision (employment.hs `hiring`) minted {@self goal {@self engage_staff
; <org_articles>}} on the WORKER. hire_errand_think routes him to the firm and, at the
; premises, runs the eligibility MATCH (the select-record over the occupations table) and
; proposes {@self engage_staff ?art ?jk} - the org articles + the post he fit. This body
; just commits that hire off its act-belief and ends the errand.
; ----------------------------------------------------------------------------

(npc-action {@self engage_staff ?art ?jk}
  (duration 45)
  (effects
    (hire-seq ?art ?jk [k apprentice])
    (set-outcome {@self engage_staff} succ)))
