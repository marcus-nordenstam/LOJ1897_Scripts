; ----------------------------------------------------------------------------
; seek-indenture ?art - the DOING of taking up an apprenticeship: go to the master's
; premises, ENROL on the wage book as a clerk (trainee entry), then come to know the
; post and the master. The decision (apprenticeship_think apprenticeship_start) proposes
; this task and owns its life (it maintains the proposal while the youth is unemployed
; and not yet a trainee, then withdraws). ?art is the master's articles; his premises
; are articles-building ?art, his identity the articles' org-founder. The register
; resolution is the task's job (off the articles belief); the dumb ENROL just files the
; row at trainee - exactly the apprentice's starting rank.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")
(include "../../macros/founding.mc")

(npc-task {@self seek-indenture ?art}:?si-rel
  (tar document)
  (and
    ; GO: not at the master's premises -> travel to it.
    (try
      (when (and (articles-building ?art ?venue)
                 (not (spatial @self building ?venue))))
      (effects (maintain-proposal {@self enter ?venue})))

    ; ENROL: at the premises, not yet hired -> resolve the wage book off the articles
    ; and file my clerk row (ENROL enters at trainee).
    (try
      (when (and (articles-building ?art ?venue)
                 (spatial @self building ?venue)
                 -{@self job.salary ?}))
      (effects
        (o {?art declares-org @o}): ?org
        (any {?org employee-register ?reg})
        (check ?reg)
        (maintain-proposal {@self ENROL ?reg [k job clerk]})))

    ; REALIZE: my row is on the wage book -> mint the employment beliefs (read off the
    ; articles) and the master bond. Minting {@self job ...} trips the decision's
    ; completion gate (no longer unemployed / not trainee), which withdraws the task.
    (try
      (when (and (articles-building ?art ?venue)
                 (spatial @self building ?venue)))
      (effects
        (o {?art declares-org @o}): ?org
        (any {?org employee-register ?reg})
        (if (table-match (attr ?reg writing) worker @self level ?lvl)
            (then
              (hire-beliefs ?art [k job clerk] ?lvl)
              (org-founder ?art ?master)
              (if ?master (then (begin-belief {@self master ?master})))))))))
