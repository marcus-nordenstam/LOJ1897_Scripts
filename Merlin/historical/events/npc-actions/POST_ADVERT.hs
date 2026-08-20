; ----------------------------------------------------------------------------
; post_advert - the clerical WRITE act of the labour market (the thinks live in
; recruit_think.hs / job_search_think.hs). Pen-changes-paper: a posting comes
; off the board onto it. An org is a mental-only object and never an act
; participant - every participant is paper or people.
;
; RECRUITER: write the job advert onto the parish board. The org's articles (?art) are the
; act's target; the advert copies the workplace off them and backlinks them as org_record.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self POST_ADVERT ?art ?jk}
  (duration 20)
  (effects
    (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
    (create-entity [k job_description]
        (qual location (spatial @self building))): ?ad
    (write-doc-record [k job_description] ?ad
        (org_record ?art) (job ?jk) (level [k trainee])
        (salary (lookup income_by_level level [k trainee] income 0))
        (class_floor (lookup occupations job ?jk class_floor [k lower]))
        (workplace ?wp))
    (set-outcome {@self POST_ADVERT ?art ?jk} succ)))
