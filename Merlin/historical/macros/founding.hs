; ----------------------------------------------------------------------------
; founding.hs - the org-founding belief sequence, as atomic .hse ops.
;
; This is the DECOMPOSITION of the old monolithic C++ (found-org) effect: the
; documents + every belief the FOUNDER/head holds are minted here, in the .hse DSL,
; over the atomic ops. Only the irreducibly-C++ primitives remain ops:
;   (acquire-org-premises ...) - the spatial verb (acquire an existing unoccupied
;                              building from the pool + the founder's title deed +
;                              an apothecary's poison stock); a dry pool binds ?wp to
;                              a fail value (no abort) and the (if ?wp ...) guard
;                              below skips the founding; see
;                              hsim_org_lifecycle::acquire_org_premises.
;   (stamp-work-hours ...)   - the shift stamp, reading the occupation_shifts
;                              (define-table) rows for the job kind.
;
; STAFFING is NOT done here. A new org is founded with its HEAD only; the emergent
; labour market staffs it over subsequent ticks: the recruit_staff duty-holder posts
; a parish-board advert (recruit_think.hs), jobless seekers read the board and apply
; in person (job_search_think.hs), the recruiter decides over his applicants book,
; letters go out, and the accepted hire is enrolled on the wage book - which the
; new employee READS to realize his employment. No bulk scan, no telepathy.
;
; The head's job is passed as a SCOPED job kind ([k job <role>]) so it serves three
; roles unchanged: the head's job mental-object kind, the roster `job` field, and
; the work-hours catalog key. A plain business passes [k job proprietor].
;
;   (found-org-seq ?org-kind ?head-role)
;     ?org-kind  - the org kind value ([k org church] / a rolled [k org bakery])
;     ?head-role - the founder's job, a scoped job kind ([k job priest])
; ----------------------------------------------------------------------------

(define-macro found-org-seq (?org-kind ?head-role)
  (do
    ; --- spatial premises (C++): acquire an existing building + title deed + stock.
    ; A dry pool binds ?wp to a fail value (no abort); every step below is gated on
    ; (if ?wp ...) so a premises-less founding mints NOTHING - no malformed org, no
    ; error. Founding paths roll only housable kinds, so this is the race / belt path.
    (tolerate (acquire-org-premises ?org-kind @self):?wp)
    (if ?wp
      (then
        ; ?wp is the workplace BUILDING. The head LEARNS its rooms up front (the building
        ; parts that are rooms): {building room <room>} + the reverse {room building}. The
        ; founder owns the premises, so this stands in for having explored it.
        (for-each ?room (spatial ?wp parts [k interior_space room] /env)
            (learn-containment ?room ?wp))
        ; --- the org's documents (abs-native): articles + an empty register -------
        ; A document must live in a SPACE, never at the building - so seed them in one of
        ; the workplace's rooms, which the head now knows. Containment is engine-written
        ; (the spatial index) - read it via (spatial ?wp room), never a {?wp room ?} belief.
        (spatial ?wp room): ?back
        (check ?back)
        (create-entity [k articles_of_incorporation] (qual location ?back)): ?art
        (create-entity [k employee_register]          (qual location ?back)): ?reg
        (table-init ?reg worker job level)

        ; --- founder's mind: the org object + its constitutive beliefs ------------
        (o ?org-kind {?art declares_org @o}): ?org
        (table-match businesses org_kind ?org-kind name ?org-name)
        (begin-belief {?org isa ?org-kind})
        (begin-belief {?org founder @self})
        (begin-belief {?org workplace ?wp})
        (begin-belief {?org name ?org-name})
        (begin-belief {?org record ?art})
        (begin-belief {?org employee_register ?reg})

        ; --- the articles DOCUMENT: the constitutive sentences a STRANGER reads (via
        ; orient) to reconstruct the org. Composed with (msg ..), so each ?org / @self
        ; reference REG-externalizes to its name for any reader. Known-org readers use
        ; their own beliefs above and never touch this doc.
        (set-writing ?art (written-msg {?art declares_org ?org}
                                       {?org isa ?org-kind}
                                       {?org founder @self}
                                       {?org workplace ?wp}
                                       {?org employee_register ?reg}
                                       {?org name ?org-name}))

        ; --- seat the founder as HEAD: roster + head-job beliefs -------------------
        ; ?head-role is a job KIND that is-a org_head (so {@self job [k org_head]}
        ; matches). Heading an org is NOT employment - the head job carries NO salary.
        (table-add ?reg worker @self job ?head-role level [k senior])
        (begin-belief {?wp occupant @self})
        ; the head job object: org (job.org), seniority, work-hours. No salary (unpaid).
        (o ?head-role {@self job @o}): ?job
        (begin-belief {?job org ?org})
        (begin-belief {?job level [k senior]})
        (begin-belief {?job since (year)})
        (stamp-work-hours ?job ?head-role)
        ; org registry: record that one more org of this kind now exists.
        (add-attr-item @gm all_org_kinds ?org-kind)))))

; ----------------------------------------------------------------------------
; found-club-seq - the CLUB analogue of found-org-seq.
;
; A club has MEMBERS, not employees: no head is seated, no employment beliefs are
; minted. So this is found-org-seq with the head-enrol block replaced by a single
; (register-member @self) - the founder is the club's first member (member_of, not
; employer). Premises are acquired exactly as for any org (acquire-org-premises:
; same building-kind catalog + pool acquisition + title deed); a dry pool binds ?wp
; to a fail value and the (if ?wp ...) guard skips the founding (clubs are not
; premises-gated upstream, so this is the only dry-pool handling).
;
;   (found-club-seq ?club-kind)
;     ?club-kind - the rolled club kind value ([k org race_club] / [k org athletic_club])
; ----------------------------------------------------------------------------

(define-macro found-club-seq (?club-kind)
  (do
    (tolerate (acquire-org-premises ?club-kind @self):?wp)
    (if ?wp
      (then
        ; ?wp is the clubhouse BUILDING. The founder LEARNS its rooms up front (owning the
        ; premises stands in for exploring it): {building room} + the reverse {room building}.
        (for-each ?room (spatial ?wp parts [k interior_space room] /env)
            (learn-containment ?room ?wp))
        ; --- the club's documents (abs-native): articles + an empty register -----
        ; A document lives in a SPACE, never at the building - seed them in a clubhouse
        ; room, read off the engine-written spatial index (never a {?wp room ?} belief).
        (spatial ?wp room): ?back
        (check ?back)
        (create-entity [k articles_of_incorporation] (qual location ?back)): ?art
        (create-entity [k employee_register]          (qual location ?back)): ?reg
        (table-init ?reg worker job level)

        ; --- founder's mind: the org object + its constitutive beliefs -----------
        (o ?club-kind {?art declares_org @o}): ?org
        (table-match businesses org_kind ?club-kind name ?org-name)
        (begin-belief {?org isa ?club-kind})
        (begin-belief {?org founder @self})
        (begin-belief {?org workplace ?wp})
        (begin-belief {?org name ?org-name})
        (begin-belief {?org record ?art})
        (begin-belief {?org employee_register ?reg})
        ; the articles DOCUMENT: constitutive sentences a stranger READs (orient) to
        ; reconstruct the club (org REG-externalizes to its name via written-msg).
        (set-writing ?art (written-msg {?art declares_org ?org}
                                       {?org isa ?club-kind}
                                       {?org founder @self}
                                       {?org workplace ?wp}
                                       {?org employee_register ?reg}
                                       {?org name ?org-name}))

        ; --- the founder is the club's first MEMBER (member_of, not employment) ---
        ; a membership roster row [member membership] (no level - a club membership
        ; carries no rank) + the member_of belief in his own mind. ?reg / ?org bound above.
        (table-add ?reg worker @self job [k membership])
        (begin-belief {@self member_of ?org})
        ; org registry: record that one more org of this kind now exists.
        (add-attr-item @gm all_org_kinds ?club-kind)))))

; ----------------------------------------------------------------------------
; hire-beliefs - the BELIEF-ONLY half of hiring (no roster write).
;
; Reads the org's kind + premises off the existing articles and mints every
; employment belief in @self's mind. It does NOT touch the roster - the worker is
; rostered separately: hire-seq (below) writes the register itself for an emergent
; hire, while the C++ candidate-scan effects (bootstrap / staff_household / jockey)
; roster the worker via the thin enrol verb and let the materialize_employment
; rule call THIS to mint the beliefs. So the beliefs live in .hs; the roster
; (objective) is owned by whoever enrolled the worker. @self is always the worker
; (no telepathy). Only (stamp-work-hours) (the occupation_shifts table stamp)
; reaches outside @self's own mind.
;
;   (hire-beliefs ?art ?job-kind ?level)  - args as hire-seq below.
; ----------------------------------------------------------------------------

(define-macro hire-beliefs (?art ?job-kind ?level)
  (do
    ; --- learn the org off the articles: a new hire READs the incorporation page.
    ; adopt-msg reconstructs the org object (by name-REG) + its constitutive beliefs
    ; ({?art declares_org ?org} / {?org isa} / {?org workplace} / {?org employee_register}).
    (adopt-msg (attr ?art writing))
    ; --- @self's mind: recall the org just learned (anchored to the articles) + its
    ; premises, then mint the employment beliefs.
    (o {?art declares_org @o}): ?org
    {?org workplace ?wp}
    (begin-belief {?wp occupant @self})
    ; @self LEARNS the workplace's rooms (the building's `parts` that are rooms):
    ; {building room <room>} + the reverse {room building <building>}.
    (for-each ?room (spatial ?wp parts [k interior_space room] /env)
        (learn-containment ?room ?wp))
    ; --- the job mental object: org (job.org), rank (level), salary, work-hours ---
    ; This is a HIRED (paid) post, so the job carries a salary decoration; heads
    ; seated by found-org-seq mint NO salary (heading != being employed). The org
    ; lives ON the job object, so {@self job.org ?} chains (no separate employer).
    ; salary IS the yearly income (0 = unsalaried), read from income_by_level.
    (table-match income_by_level level ?level income ?salary)
    (o ?job-kind {@self job @o}): ?job
    (begin-belief {?job org ?org})
    (begin-belief {?job level ?level})
    (begin-belief {?job salary ?salary})
    (begin-belief {?job since (year)})
    (stamp-work-hours ?job ?job-kind)))

; ----------------------------------------------------------------------------
; hire-seq - the full WORKER-side hire: roster write + employment beliefs.
;
; The decomposition of the old monolithic C++ hire() belief-mint, mirroring
; found-org-seq: where founding CREATES the org's documents + premises, hiring
; READS them from the existing articles, ENROLS @self on the register, and mints
; his beliefs (hire-beliefs). The emergent hire paths use this - the worker is not
; yet rostered, so it must both enrol him AND mint his beliefs. In every emergent
; path the worker IS @self (hire_commit / indenture / partner: @self;
; senior_appointment: @self == the role-0 official), so there is NO telepathy.
;
;   (hire-seq ?art ?job-kind ?level)
;     ?art       - the org's articles document (the goal focus / appointment org)
;     ?job-kind  - the worker's SCOPED job kind ([k job clerk], a matched (bind ?jk),
;                  [k job proprietor], ...): the roster `job` field, the job mental
;                  object kind, AND the work-hours catalog key (same triple role as
;                  found-org-seq's ?head-role).
;     ?level     - the starting rank ([k apprentice] / [k trainee] / [k senior] / ...)
;
; STAFFING note: the matched job kind comes from hire_errand_act's
; (select-record ...) over the occupations table, which binds ?jk =
; [k job <leaf>] or @fail; the caller guards on ?jk. The fixed-role paths
; (indenture / partner / senior) pass a literal [k job <role>].
; ----------------------------------------------------------------------------

(define-macro hire-seq (?art ?job-kind ?level)
  (do
    ; --- the employment beliefs in @self's mind (reads the articles, learns the org) --
    (hire-beliefs ?art ?job-kind ?level)
    ; --- env-side roster (abs): record @self under the matched job kind + rank. The
    ; register is learned off the adopted {?org employee_register} belief.
    (o {?art declares_org @o}): ?org
    {?org employee_register ?reg}
    (table-add ?reg worker @self job ?job-kind level ?level)))

; ----------------------------------------------------------------------------
; fire-self - a worker leaves his OWN post. Scrubs @self's row off the firm's
; employee_register (a public doc, keyed on him via (find worker @self)) and
; ends his OWN {@self job} belief (its org / salary / level decorations go with
; it). The register is reached by @self's own forward belief walk: {@self job.org}
; -> {org record} -> the articles' `register` field. Every step is @self / a
; public doc - no cross-mind write. (A boss firing SOMEONE ELSE cannot end their
; beliefs; the sacked worker reconciles his own stale row.)
; ----------------------------------------------------------------------------

(define-macro fire-self ()
  (for-each ?fire-jrel (every {@self job ?})
      ?fire-jrel.target: ?fire-job
      (for-each ?fire-orel (every {?fire-job org ?})
          ?fire-orel.target: ?fire-org
          (for-each ?fire-rrel (every {?fire-org employee_register ?})
              ?fire-rrel.target: ?fire-reg
              (table-remove ?fire-reg worker @self)))
      (end-belief ?fire-jrel)))