; ----------------------------------------------------------------------------
; resolve_applications - the clerical WRITE act of the labour market (the thinks live in
; recruit_think.hs / job_search_think.hs). Pen-changes-paper: a letter lands in a
; mail pile. An org is a mental-only object and never an act participant - every
; participant is paper or people.
;
; RECRUITER: resolve the held application batch (lifted from the office inbox by the
; take_my_letters duty scan). The FIRST held application gets the offer, the rest
; rejections; each verdict letter is a typed blank signal addressed to the applicant
; with his home as the written destination, filed into the outgoing pile ?out at
; hand; every application is destroyed so nothing accumulates.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self RESOLVE_APPLICATIONS ?art ?out}
  (duration 30)
  (effects
    ; PRECONDITION: this act only runs because the recruiter LIFTED applications from
    ; the inbox. If it holds none, the resolve is a silent no-op and no offer is ever
    ; cut - the break is upstream (application never reached the recruiter's hand).
    (check (held-items @self [k application]))
    (for-each ?app (held-items @self [k application]) /limit 1
      (do
        (read-doc-record [k application] ?app (applicant ?w))
        (create-entity [k offer_letter] (qual location (building @self))): ?ol
        (set-attr ?ol addressee (attr ?w name))
        (set-attr ?ol address (home-of ?w))
        (check (attr ?ol address))
        (debug-print "RESOLVE_OFFER w=?w ol=?ol")
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
    (set-outcome {@self RESOLVE_APPLICATIONS ?art ?out} succ)))
