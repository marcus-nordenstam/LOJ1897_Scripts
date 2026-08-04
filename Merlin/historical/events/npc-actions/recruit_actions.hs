; ----------------------------------------------------------------------------
; recruit_actions - the clerical WRITE family of the labour market (the thinks
; live in recruit_think.hs / job_search_think.hs). Every act here is PURE PHYSICAL
; EFFECT: pen changes paper (a document appears, a field is stamped, a letter
; lands in a mail pile, a posting comes off the board) and the outcome is stamped -
; NOTHING ELSE. All bookkeeping (post / submit / offering / hire-beliefs) lives in
; the npc-think rules, gated on (did-succeed {act /past}) or on the paper the act
; produced. An org is a mental-only object and never an act participant; every
; participant below is paper or people.
; ----------------------------------------------------------------------------

; RECRUITER: write the job advert onto the parish board. The org's articles (?art)
; are the act's target; the advert copies the workplace off them and backlinks
; them as its org_record. The post (?jk) rides the aux from advertise_post.
(npc-action {@self post_advert ?art ?jk}
  (duration 20)
  (effects
    (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
    (create-entity [k job_description]
        (qual location (current-building @self)) (bind ?ad))
    (write-doc-record [k job_description] ?ad
        (org_record ?art) (job ?jk) (level [k trainee]) (salary 1)
        (class_floor (lookup occupations job ?jk class_floor [k lower]))
        (workplace ?wp))
    (set-outcome {@self post_advert ?art ?jk} succ)))

; SEEKER: write an application and leave it at the workplace. It copies the post /
; org / workplace off the advert (?ad) and opens at status applied - the physical
; paper on the recruiter's desk IS the application.
(npc-action {@self submit_application ?ad}
  (duration 20)
  (effects
    (read-doc-record [k job_description] ?ad (job ?jk) (org_record ?art) (workplace ?wp))
    (create-entity [k application]
        (qual location (current-building @self)) (bind ?app))
    (write-doc-record [k application] ?app
        (applicant @self) (job ?jk) (org_record ?art) (workplace ?wp) (status [k applied]))
    ; The author holds his OWN paper's handle - {@self submit ?app} is his one
    ; dedup (closes apply_pick) and the anchor his verdict letters resolve onto.
    (begin-belief {@self submit ?app})
    (set-outcome {@self submit_application ?ad} succ)))

; RECRUITER: offer the post - stamp the application offered and post the reply
; letter to the applicant's home (the letter carries the paper's new status; the
; reader resolves the application he himself submitted).
(npc-action {@self make_offer ?app}
  (duration 15)
  (effects
    (read-doc-record [k application] ?app (applicant ?w))
    (update-doc-record [k application] ?app (status [k offered]))
    (spawn-letter [k letter]
        (written-msg {?app status [k offered]} signed) (home-of ?w))
    (set-outcome {@self make_offer ?app} succ)))

; RECRUITER: reject - stamp the application rejected and post the reply letter.
(npc-action {@self send_rejection ?app}
  (duration 15)
  (effects
    (read-doc-record [k application] ?app (applicant ?w))
    (update-doc-record [k application] ?app (status [k rejected]))
    (spawn-letter [k letter]
        (written-msg {?app status [k rejected]} signed) (home-of ?w))
    (set-outcome {@self send_rejection ?app} succ)))

; SEEKER: accept the offer - sign the application accepted at the workplace.
(npc-action {@self accept_post ?app}
  (duration 10)
  (effects
    (update-doc-record [k application] ?app (status [k accepted]))
    (set-outcome {@self accept_post ?app} succ)))

; RECRUITER: enrol the accepted hire on the wage book (?reg). The row content
; comes off the accepted application (applicant + post).
(npc-action {@self enrol ?app ?reg}
  (duration 10)
  (effects
    (read-doc-record [k application] ?app (applicant ?cand) (job ?jk))
    (write-doc-record [k employee_register] ?reg
        (worker ?cand) (job ?jk) (level [k trainee]))
    (set-outcome {@self enrol ?app ?reg} succ)))

; RECRUITER: take a filled posting off the board - the paper is removed.
(npc-action {@self take_down ?ad}
  (duration 5)
  (effects
    (destroy-entity ?ad)
    (set-outcome {@self take_down ?ad} succ)))
