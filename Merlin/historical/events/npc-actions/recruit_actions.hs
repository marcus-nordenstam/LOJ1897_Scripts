; ----------------------------------------------------------------------------
; recruit_actions - the clerical WRITE family of the labour market (the thinks live in
; recruit_think.hs / job_search_think.hs). Every act is pen-changes-paper: a document
; appears, is filed / pulled / stamped, a letter lands in a mail pile, a posting comes off
; the board. An org is a mental-only object and never an act participant - every
; participant is paper or people.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; RECRUITER: write the job advert onto the parish board. The org's articles (?art) are the
; act's target; the advert copies the workplace off them and backlinks them as org_record.
(npc-action {@self post_advert ?art ?jk}
  (duration 20)
  (effects
    (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
    (create-entity [k job_description]
        (qual location (building @self))): ?ad
    (write-doc-record [k job_description] ?ad
        (org_record ?art) (job ?jk) (level [k trainee]) (salary 1)
        (class_floor (lookup occupations job ?jk class_floor [k lower]))
        (workplace ?wp))
    (set-outcome {@self post_advert ?art ?jk} succ)))

; SEEKER: write the application paper (born wherever @self stands), envelope-addressed
; to the RECRUITING DUTY (the officer's take_my_letters duty check collects by it)
; with the org's WRITTEN street address, so the magic mail service delivers it to the
; workplace inbox once af_send hands it to the send_mail lane. Copies post / org /
; workplace off ?art + ?jk.
(npc-action {@self prepare_application ?art ?jk}
  (duration 20)
  (effects
    (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
    (create-entity [k application]
        (qual location (building @self))): ?app
    (write-doc-record [k application] ?app
        (applicant @self) (job ?jk) (org_record ?art) (workplace ?wp))
    (set-attr ?app addressee_duty [k recruit_staff])
    (set-attr ?app address ?wp)
    (set-outcome {@self prepare_application ?art ?jk} succ)))

; RECRUITER: resolve the held application batch (lifted from the office inbox by the
; take_my_letters duty scan). The FIRST held application gets the offer, the rest
; rejections; each verdict letter is a typed blank signal addressed to the applicant
; with his home as the written destination, filed into the outgoing pile ?out at
; hand; every application is destroyed so nothing accumulates.
(npc-action {@self resolve_applications ?art ?out}
  (duration 30)
  (effects
    (for-each ?app (held-items @self [k application]) /limit 1
      (do
        (read-doc-record [k application] ?app (applicant ?w))
        (create-entity [k offer_letter] (qual location (building @self))): ?ol
        (set-attr ?ol addressee (attr ?w name))
        (set-attr ?ol address (home-of ?w))
        (file-in-stack ?ol ?out)
        (destroy-entity ?app)))
    (for-each ?app (held-items @self [k application])
      (do
        (read-doc-record [k application] ?app (applicant ?w))
        (create-entity [k rejection_letter] (qual location (building @self))): ?rl
        (set-attr ?rl addressee (attr ?w name))
        (set-attr ?rl address (home-of ?w))
        (file-in-stack ?rl ?out)
        (destroy-entity ?app)))
    (set-outcome {@self resolve_applications ?art ?out} succ)))

; SEEKER: take up the offered post - write his own row onto the wage book (?jk from the
; still-running apply_for). Reading his row back (tup_read_book) realizes employment.
(npc-action {@self take_post ?art ?jk}
  (duration 15)
  (effects
    (read-doc-record [k articles_of_incorporation] ?art (register ?reg))
    (write-doc-record [k employee_register] ?reg
        (worker @self) (job ?jk) (level [k trainee]))
    (set-outcome {@self take_post ?art ?jk} succ)))

; RECRUITER: take a filled posting off the board - the paper is removed.
(npc-action {@self take_down ?ad}
  (duration 5)
  (effects
    (destroy-entity ?ad)
    (set-outcome {@self take_down ?ad} succ)))
