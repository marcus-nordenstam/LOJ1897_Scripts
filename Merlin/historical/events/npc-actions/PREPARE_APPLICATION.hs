; ----------------------------------------------------------------------------
; prepare_application - the clerical WRITE act of the labour market (the thinks live in
; recruit_think.hs / job_search_think.hs). Pen-changes-paper: the application paper
; is born. An org is a mental-only object and never an act participant - every
; participant is paper or people.
;
; SEEKER: write the application paper (born wherever @self stands), envelope-addressed
; to the RECRUITING DUTY (the officer's take_my_letters duty check collects by it)
; with the org's WRITTEN street address, so the magic mail service delivers it to the
; workplace inbox once af_send hands it to the send_mail lane. Copies post / org /
; workplace off ?art + ?jk.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self PREPARE_APPLICATION ?art ?jk}
  (duration 20)
  (effects
    (read-doc-record [k articles_of_incorporation] ?art (spatial ?wp building))
    (if (substantial ?wp)
      (then
        (create-entity [k application]
            (qual location (spatial @self building))): ?app
        (write-doc-record [k application] ?app
            (applicant @self) (job ?jk) (org_record ?art) (workplace ?wp))
        (set-attr ?app addressee_duty recruit_staff)
        (set-attr ?app address ?wp)))
    (set-outcome {@self PREPARE_APPLICATION ?art ?jk} succ)))
