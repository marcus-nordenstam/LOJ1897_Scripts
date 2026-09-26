; DORMANT - this lane never ran; revived on the form deeds / articles with its own gauntlet.
;; ----------------------------------------------------------------------------
;; seek-indenture ?art - the DOING of taking up an apprenticeship: go to the master's
;; premises, ENROL on the wage book as a clerk (trainee entry), then come to know the
;; post and the master. The decision (apprenticeship_think apprenticeship_start) proposes
;; this task and owns its life (it maintains the proposal while the youth is unemployed
;; and not yet a trainee, then withdraws). ?art is the master's articles; his premises
;; are the articles' workplace, his identity the articles' org-founder. The register
;; resolution is the task's job (off the articles belief); the dumb ENROL just files the
;; row at trainee - exactly the apprentice's starting rank.
;; ----------------------------------------------------------------------------

;(include "../../macros/founding.mc")

;(npc-task {@self seek-indenture ?art}:?si-rel
;  (tar [k document] @object)
;  (and
;    ; GO: not at the master's premises -> travel to it.
;    (try
;      (role ?art_org {?art_org record ?art}
;                      {?art_org workplace ?venue}
;                      (not (spatial @self building ?venue))
;        (effects (maintain-proposal {@self go ?venue}))))

;    ; LOCATE: at the premises, the wage book the articles name not yet found there -> find it.
;    (try
;      (role ?org {?art declares-org ?org}
;                 {?org workplace ?venue}
;                 (spatial @self building ?venue)
;        (role ?reg {?org employee-register ?reg}
;                   (not (spatial ?reg building ?venue))
;          (when -{@self job.salary ?})
;          (effects (maintain-proposal {@self locate ?reg ?venue})))))

;    ; ENROL: at the premises, not yet hired, the wage book found there -> file my clerk row
;    ; (ENROL enters at trainee).
;    (try
;      (role ?org {?art declares-org ?org}
;                 {?org workplace ?venue}
;                 (spatial @self building ?venue)
;        (role ?reg {?org employee-register ?reg}
;                   (spatial ?reg building ?venue)
;          (when -{@self job.salary ?})
;          (effects (maintain-proposal {@self ENROL ?reg '[[k job clerk] [k trainee]]})))))

;    ; REALIZE: my row is on the wage book -> mint the employment beliefs (read off the
;    ; articles) and the master bond. Minting {@self job ...} trips the decision's
;    ; completion gate (no longer unemployed / not trainee), which withdraws the task.
;    (try
;      (role ?art_org {?art_org record ?art}
;                      {?art_org workplace ?venue}
;                      (spatial @self building ?venue)
;        (effects
;          (o {?art declares-org @o}): ?org
;          (any {?org employee-register ?reg})
;          (if (table-match (attr ?reg writing) worker (name @self) level ?lvl)
;              (then
;                (hire-beliefs ?art [k job clerk] ?lvl)
;                (org-founder ?art ?master)
;                (if ?master (then (begin-belief {@self master ?master})))
;                (set-outcome ?si-rel /succ))))))))
