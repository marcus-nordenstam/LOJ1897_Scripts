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
;   (stamp-work-hours ...)   - reuse of the occupation-catalog shift stamp that
;                              hire() still depends on (retires with hire(), step 4).
;
; STAFFING is NOT done here. A new org is founded with its HEAD only; the emergent
; labour market staffs it over subsequent ticks from the unemployed pool - the
; role-enumerated `hiring` event (employment.hs) mints an engage_staff goal on a
; jobless adult, hire_errand walks him to the firm, and (match-job) + (hire-seq)
; commit the eligibility-matched hire. No bulk population scan, no catalog headcount.
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
    (acquire-org-premises ?org-kind @self (bind ?wp))
    (if ?wp
      (do
        ; --- the org's documents (abs-native): articles + an empty register -------
        (create-entity [k articles_of_incorporation] (qual location ?wp) (bind ?art))
        (create-entity [k employee_register]          (qual location ?wp) (bind ?reg))
        (write-doc-record [k articles_of_incorporation] ?art
            (kind ?org-kind) (founder @self) (building ?wp) (year (year)) (register ?reg))

        ; --- founder's mind: the org object + its constitutive beliefs ------------
        (imagine-or-recall ?org-kind {?art declares_org ?org})
        ; the org object's KIND as a queryable belief (imagine-or-recall sets the
        ; object kind but mints no isa belief; the belief-pure casting filters read
        ; isa, so every org-object-formation site mints it - keeps the cache matcher
        ; and the live (believes) op reading the same fact). Read the kind back into
        ; a let-bound ?ok: a macro PARAM (?org-kind) is not in let_names, so as a
        ; begin-belief pattern TARGET it reads as a free ?var (flatten_pattern_field
        ; resolves targets via var_is_bound only); the doc read binds ?ok properly.
        (read-doc-record [k articles_of_incorporation] ?art (kind ?ok))
        (begin-belief {?org isa ?ok})
        (begin-belief {?org founder @self})
        (begin-belief {?org workplace ?wp})
        (begin-belief {?org record ?art})

        ; --- seat the founder as HEAD (org_head): roster + employment beliefs -----
        (write-doc-record [k employee_register] ?reg
            (worker @self) (job ?head-role) (level [k org_head]))
        (begin-belief {@self employer ?org})
        (begin-belief {?wp occupant @self})
        ; the head LEARNS the workplace's rooms (the building's `parts` that are rooms):
        ; {building room <room>} + the reverse {room building <building>}.
        (for-each ?room (attr-values ?wp parts [k interior_space room])
            (begin-belief {?wp room ?room})
            (begin-belief {?room building ?wp}))
        ; the job mental object carrying the org_head rank, plus its work-hours.
        (imagine-or-recall ?head-role {@self job ?job})
        (begin-belief {?job level [k org_head]})
        (stamp-work-hours ?job ?head-role)))))

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
    (acquire-org-premises ?club-kind @self (bind ?wp))
    (if ?wp
      (do
        ; --- the club's documents (abs-native): articles + an empty register -----
        (create-entity [k articles_of_incorporation] (qual location ?wp) (bind ?art))
        (create-entity [k employee_register]          (qual location ?wp) (bind ?reg))
        (write-doc-record [k articles_of_incorporation] ?art
            (kind ?club-kind) (founder @self) (building ?wp) (year (year)) (register ?reg))

        ; --- founder's mind: the org object + its constitutive beliefs -----------
        (imagine-or-recall ?club-kind {?art declares_org ?org})
        ; read the kind back into a let-bound ?ok (macro param ?club-kind is not in
        ; let_names, so it reads free as a begin-belief pattern target - see found-org-seq).
        (read-doc-record [k articles_of_incorporation] ?art (kind ?ok))
        (begin-belief {?org isa ?ok})    ; queryable kind belief - see found-org-seq
        (begin-belief {?org founder @self})
        (begin-belief {?org workplace ?wp})
        (begin-belief {?org record ?art})

        ; --- the founder is the club's first MEMBER (member_of, not employment) ---
        (register-member /articles ?art /member @self)))))

; ----------------------------------------------------------------------------
; hire-beliefs - the BELIEF-ONLY half of hiring (no roster write).
;
; Reads the org's kind + premises off the existing articles and mints every
; employment belief in @self's mind. It does NOT touch the roster - the worker is
; rostered separately: hire-seq (below) writes the register itself for an emergent
; hire, while the C++ candidate-scan effects (bootstrap / staff_household / jockey)
; roster the worker via the thin enrol verb and let the materialize_employment
; event call THIS to mint the beliefs. So the beliefs live in .hs; the roster
; (objective) is owned by whoever enrolled the worker. @self is always the worker
; (no telepathy). Only (stamp-work-hours) (occupation-catalog reuse) reaches
; outside @self's own mind.
;
;   (hire-beliefs ?art ?job-kind ?level)  - args as hire-seq below.
; ----------------------------------------------------------------------------

(define-macro hire-beliefs (?art ?job-kind ?level)
  (do
    ; --- read the org's kind + premises off the existing articles --------------
    (read-doc-record [k articles_of_incorporation] ?art
        (kind ?org-kind) (building ?wp))
    ; --- @self's mind: the org object + the employment beliefs ------------------
    (imagine-or-recall ?org-kind {?art declares_org ?org})
    (begin-belief {?org isa ?org-kind})    ; queryable kind belief - see found-org-seq
    (begin-belief {@self employer ?org})
    (begin-belief {?wp occupant @self})
    (begin-belief {?org workplace ?wp})
    ; @self LEARNS the workplace's rooms (the building's `parts` that are rooms):
    ; {building room <room>} + the reverse {room building <building>}.
    (for-each ?room (attr-values ?wp parts [k interior_space room])
        (begin-belief {?wp room ?room})
        (begin-belief {?room building ?wp}))
    ; --- the job mental object carrying the rank, plus its work-hours -----------
    (imagine-or-recall ?job-kind {@self job ?job})
    (begin-belief {?job level ?level})
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
; STAFFING note: the matched job kind comes from (match-job ...) (C++: the
; occupation catalog + career scan) which binds ?jk = [k job <leaf>] or @fail;
; the caller guards (if ?jk (hire-seq ... ?jk ...)). The fixed-role paths
; (indenture / partner / senior) pass a literal [k job <role>].
; ----------------------------------------------------------------------------

(define-macro hire-seq (?art ?job-kind ?level)
  (do
    ; --- env-side roster (abs): record @self under the matched job kind + rank --
    (read-doc-record [k articles_of_incorporation] ?art (register ?reg))
    (write-doc-record [k employee_register] ?reg
        (worker @self) (job ?job-kind) (level ?level))
    ; --- the employment beliefs in @self's mind --------------------------------
    (hire-beliefs ?art ?job-kind ?level)))
