; ----------------------------------------------------------------------------
; founding.hs - the org-founding belief sequence, as atomic .hse ops.
;
; This is the DECOMPOSITION of the old monolithic C++ (found-org) effect: the documents +
; every belief the FOUNDER/head holds are minted here, in the .hse DSL. Premises are claimed
; off the land registry (found-org-seq scans the title_deeds for a vacant one of the org's
; building kind and stamps @self as its owner), not acquired from a C++ pool. The one op still
; reaching outside @self's mind is:
;   (stamp-work-hours ...) - the shift stamp, reading the occupation_shifts table for the job.
;
; STAFFING is NOT done here. A new org is founded with its HEAD only; the emergent
; labour market staffs it over subsequent ticks: the recruit-staff duty-holder posts
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

(include "adopt-aoc.mc")

; name-premises - an org that NAMES its building (businesses names-building = yes: a pub, a
; hotel, a factory) gives the building its `name` and hangs the building-name-sign. The
; name is the BUILDING's from then on - it is the premises' identity, not the org's, so a
; building already named keeps its name (first namer wins; a later tenant works "at the
; Laughing Pig"). The sign is a structural PART of the building at a zero local offset,
; which puts it on the fixture walk perception runs when the building itself is perceived.
; An org that does not name its building mounts nothing: the building's address-sign (seeded
; at world setup) is its identity, and an org has no sign of its own.
(define-macro name-premises (?bldg ?org-kind ?org-name)
  (do
    (bind ?bldg ?np-bldg)
    (bind ?org-name ?np-name)
    (table-match businesses org-kind ?org-kind names-building ?np-names)
    (if (and (substantial ?np-name)
             (= ?np-names yes)
             (not (substantial (attr ?np-bldg name))))
      (then
        (set-attr ?np-bldg name ?np-name)
        (create-entity [k building-name-sign] (floats 0 0 0) ?np-bldg): ?np-sign
        (set-attr ?np-sign name ?np-name)))))

; found-org-seq - read the house-agency's for-sale REGISTER for a premises of the org's
; building kind (businesses-table `building`, unlisted -> office), claim it, and found the
; org on it. Scanning the compressed register table (not the whole deed registry) is the
; knowledge channel: the founder consults the published listings, claims the first row of
; the right kind (table-set the deed's owner + drop the row), and founds. No such row ->
; NOTHING is minted (no malformed org, no error).
(define-macro found-org-seq (?org-kind ?head-role)
  (do
    (if (table-match businesses org-kind ?org-kind building ?bk)
        (then ?bk) (else [k building office])): ?want-kind
    (for-each ?listings (env-entities [k for-sale-listings])
      (for-each-row (attr ?listings writing) [/building ?wp] [/deed ?deed]
        (if (is-a ?wp ?want-kind)
          (then
            ; CLAIM: stamp @self as the premises' owner + pull the row off the register.
            (table-set ?deed owner @self)
            (table-remove ?listings building ?wp)
            (take-premises ?wp)
            ; The org's documents (articles + an empty register), seeded in a room (a
            ; document must live in a SPACE, never at the building).
            (spatial ?wp room): ?back
            (check ?back)
            (create-entity [k articles-of-incorporation] ?back): ?art
            (create-entity [k employee-register]         ?back): ?reg
            (table-init ?reg line worker job level)
            (establish-posts ?reg ?org-kind)
            ; The articles DOCUMENT the org into being: a one-row TABLE of its constitutive
            ; cells. This is the whole ENVIRONMENT half of founding - the org has no other
            ; objective existence.
            (table-match businesses org-kind ?org-kind name ?org-name)
            (table-init ?art org-kind org_name founder workplace register)
            (table-add ?art org-kind ?org-kind org_name ?org-name founder @self
                            workplace ?wp register ?reg)
            (name-premises ?wp ?org-kind ?org-name)
            ; File the AOC at the companies house (the company registry's incorporation
            ; stack), not the org's own premises - the town's org record lives there.
            (head (env-entities [k incorporation-stack])): ?ist
            (if ?ist (then (push ?art ?ist)))
            (seat-org-head ?art ?wp ?reg ?head-role)
            (break)))))))

; take-premises - the head takes possession of the org's building: he SEES it and its rooms
; (a placement write resolves passively, so an unseen room cannot be written about) and
; learns which building they belong to. Owning the premises stands in for exploring them.
(define-macro take-premises (?wp)
  (do
    (observe ?wp)
    (for-each ?room (spatial ?wp parts [k interior-space room] /env)
      (observe ?room)
      (spatial-write ?room struct_parent ?wp))))

; seat-org-head - the MENTAL half of founding, shared by every route into a head seat. The
; head gets his org object the same way anyone else does: he LOOKS AT the articles and READS
; them through adopt-aoc, the one decoder (ORIENT and hire-beliefs call it too) - no
; privileged minting. adopt-aoc anchors the org to the articles, so the org is READ BACK off
; that anchor rather than searched for a second time. Heading is NOT employment - no salary.
(define-macro seat-org-head (?art ?wp ?reg ?head-role)
  (do
    (observe ?art)
    (adopt-aoc ?art)
    (any {?art declares-org ?org})
    (begin-belief {?org record ?art})
    (fill-post ?reg ?head-role [k senior])
    (begin-belief {?wp occupant @self})
    ; The head's seat is a ledger line like any other - keyed on it, so his own job object
    ; is the one every later reader of this book lands on.
    (if (table-match (attr ?reg writing) worker (name @self) job ?head-role line ?soh-line)
        (then
          (o ?head-role {@o org ?org} {@o job-ledger-line-no ?soh-line}): ?job
          (begin-belief {?job org ?org})
          (begin-belief {?job job-ledger-line-no ?soh-line})
          (begin-belief {?job filled-by @self})
          (begin-belief {@self job ?job})
          (begin-belief {?job level [k senior]})
          (begin-belief {?job since (year)})
          (stamp-work-hours ?job ?head-role)))))

; take-up-charter - found an org the town already chartered: the premises, articles and staff
; book exist and only the head seat is open, so founding is writing @self into the founder
; cell and seating himself. The deed is NOT claimed - taking a post is not buying the
; premises.
;
;   (take-up-charter ?art ?head-role)
;     ?art       - a headless articles-of-incorporation (see headless-charter)
;     ?head-role - the head's job, a scoped job kind ([k job superintendent])
(define-macro take-up-charter (?art ?head-role)
  (for-each-row (attr ?art writing) [/workplace ?wp] [/register ?reg] [/take-premises ?wp]
    (table-set ?art founder @self)
    (seat-org-head ?art ?wp ?reg ?head-role)))

; ----------------------------------------------------------------------------
; found-club-seq - the CLUB analogue of found-org-seq.
;
; A club has MEMBERS, not employees: no head is seated, no employment beliefs are minted -
; the founder is enrolled as the first member (member-of, not employer). Premises are claimed
; off the land registry exactly as found-org-seq does (the clubhouse building kind comes from
; the businesses table); no free clubhouse -> nothing is minted.
;
;   (found-club-seq ?club-kind)
;     ?club-kind - the rolled club kind value ([k org race-club] / [k org athletic-club])
; ----------------------------------------------------------------------------

(define-macro found-club-seq (?club-kind)
  (do
    (if (table-match businesses org-kind ?club-kind building ?bk)
        (then ?bk) (else [k building office])): ?want-kind
    (for-each ?listings (env-entities [k for-sale-listings])
      (for-each-row (attr ?listings writing) [/building ?wp] [/deed ?deed]
        (if (is-a ?wp ?want-kind)
          (then
            (table-set ?deed owner @self)
            (table-remove ?listings building ?wp)
            (for-each ?room (spatial ?wp parts [k interior-space room] /env)
                (spatial-write ?room struct_parent ?wp))
            (spatial ?wp room): ?back
            (check ?back)
            (create-entity [k articles-of-incorporation] ?back): ?art
            (create-entity [k employee-register]         ?back): ?reg
            (table-init ?reg line worker job level)
            (o ?club-kind {?art declares-org @o}): ?org
            (table-match businesses org-kind ?club-kind name ?org-name)
            (begin-belief {?org isa ?club-kind})
            (begin-belief {?org founder @self})
            (begin-belief {?org workplace ?wp})
            (begin-belief {?org name ?org-name})
            (begin-belief {?org record ?art})
            (begin-belief {?org employee-register ?reg})
            (table-init ?art org-kind org_name founder workplace register)
            (table-add ?art org-kind ?club-kind org_name ?org-name founder @self
                            workplace ?wp register ?reg)
            (name-premises ?wp ?club-kind ?org-name)
            (head (env-entities [k incorporation-stack])): ?ist
            (if ?ist (then (push ?art ?ist)))
            ; The founder is the club's first MEMBER ([k membership] roster row, no level)
            ; + a {@self member-of} belief - not seated as a head.
            (table-add ?reg worker (name @self) job [k membership])
            (begin-belief {@self member-of ?org})
            (break)))))))

; ----------------------------------------------------------------------------
; hire-beliefs - the BELIEF-ONLY half of hiring (no roster write).
;
; Reads the org's kind + premises off the existing articles and mints every
; employment belief in @self's mind. It does NOT touch the roster - the worker is
; rostered separately: hire-seq (below) writes the register itself for an emergent
; hire, while the C++ candidate-scan effects (bootstrap / staff-household / jockey)
; roster the worker via the thin enrol verb and let the materialize_employment
; rule call THIS to mint the beliefs. So the beliefs live in .hs; the roster
; (objective) is owned by whoever enrolled the worker. @self is always the worker
; (no telepathy). Only (stamp-work-hours) (the occupation_shifts table stamp)
; reaches outside @self's own mind.
;
;   (hire-beliefs ?art ?job-kind ?level)  - args as hire-seq below.
; ----------------------------------------------------------------------------

; employ-beliefs - @self now works for ?org at ?wp as ?job-kind at ?level: the employment
; beliefs a hire mints once the org is KNOWN (by whatever route - the articles, or the
; notice that named it). The premises' rooms are learned, the job object minted with its
; org / level / salary / since and its work hours stamped.
;
; @self reads back the LINE he was just written onto, because a job IS its line on the
; org's ledger. That is what makes this the SAME object the recruiting officer keeps and a
; colleague reads off the roster, rather than a private second copy of the one seat. He
; must already be on the book - every caller matches his row before getting here.
; ?reg is handed IN, never re-derived: a man taken on off a NOTICE never read the articles,
; so he holds no {?org employee-register ?reg} belief - he found the book by perceiving it.
(define-macro employ-beliefs (?org ?wp ?job-kind ?level ?reg)
  (do
    (begin-belief {?wp occupant @self})
    (for-each ?room (spatial ?wp parts [k interior-space room] /env)
        (spatial-write ?room struct_parent ?wp))
    (table-match income_by_level level ?level income ?salary)
    (if (table-match (attr ?reg writing) worker (name @self) job ?job-kind line ?eb-line)
        (then
          (o ?job-kind {@o org ?org} {@o job-ledger-line-no ?eb-line}): ?job
          (begin-belief {?job org ?org})
          (begin-belief {?job job-ledger-line-no ?eb-line})
          (begin-belief {?job filled-by @self})
          (begin-belief {@self job ?job})
          (begin-belief {?job level ?level})
          (begin-belief {?job salary ?salary})
          (begin-belief {?job since (year)})
          (stamp-work-hours ?job ?job-kind)))))

(define-macro hire-beliefs (?art ?job-kind ?level)
  (do
    ; --- learn the org off the articles: a new hire READs the incorporation page.
    ; adopt-aoc decodes the AOC table into the org object + its constitutive beliefs
    ; ({?art declares-org ?org} / {?org isa} / {?org workplace} / {?org employee-register}).
    (adopt-aoc ?art)
    ; --- @self's mind: recall the org just learned (anchored to the articles) + its
    ; premises, then mint the employment beliefs.
    (o {?art declares-org @o}): ?org
    {?org workplace ?wp}
    {?org employee-register ?hb-reg}
    (employ-beliefs ?org ?wp ?job-kind ?level ?hb-reg)))


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
; (select-row ...) over the occupations table, which binds ?jk =
; [k job <leaf>] or @fail; the caller guards on ?jk. The fixed-role paths
; (indenture / partner / senior) pass a literal [k job <role>].
; ----------------------------------------------------------------------------

; The roster write comes FIRST: the employment beliefs key the job object on the ledger
; line, so the line has to exist before they are minted. That ordering is why this does
; not go through hire-beliefs - it would derive the org a second time, and the register
; has to be in hand before the write, not after.
(define-macro hire-seq (?art ?job-kind ?level)
  (do
    ; --- learn the org off the articles (adopt-aoc), then the register and premises it names.
    (adopt-aoc ?art)
    (o {?art declares-org @o}): ?org
    {?org employee-register ?reg}
    {?org workplace ?wp}
    ; --- env-side roster (abs): record @self under the matched job kind + rank.
    (fill-post ?reg ?job-kind ?level)
    ; --- the employment beliefs in @self's mind, off the line he now holds.
    (employ-beliefs ?org ?wp ?job-kind ?level ?reg)))

; ----------------------------------------------------------------------------
; fire-self - a worker leaves his OWN post. Scrubs @self's row off the firm's
; employee-register (a public doc, keyed on him via (find worker (name @self))) and
; ends his OWN {@self job} belief (its org / salary / level decorations go with
; it). The register is reached by @self's own forward belief walk: {@self job.org}
; -> {org record} -> the articles' `register` field. Every step is @self / a
; public doc - no cross-mind write. (A boss firing SOMEONE ELSE cannot end their
; beliefs; the sacked worker reconciles his own stale row.)
; ----------------------------------------------------------------------------

; strike-from-register - the EMPLOYER's half of a dismissal. @self walks his OWN
; belief chain to his OWN firm's employee-register (a public doc) and strikes the
; worker's row. He cannot end the worker's {job} belief - that is the worker's own
; to reconcile off the struck row, the same way an emigrant's stale row lapses.
(define-macro strike-from-register (?worker)
  (for-each ?sr-jrel (every {@self job ?})
      (bind ?sr-jrel.target ?sr-job)
      (for-each ?sr-orel (every {?sr-job org ?})
          (bind ?sr-orel.target ?sr-org)
          (for-each ?sr-rrel (every {?sr-org employee-register ?})
              (bind ?sr-rrel.target ?sr-reg)
              (vacate-post ?sr-reg ?worker)))))

; stamp-work-hours - the shift stamp. Reads the authored occupation_shifts rows for
; ?job-kind (falling back to the `default` Mon-Sat week when the kind has none) and
; mints one {?job <day>-hours <start> <end>} belief per day of ONE shift. A kind
; authored under several shift-ids (nurse / factory-worker: day AND night) puts the
; worker on exactly one, drawn here.
(define-macro stamp-work-hours (?job ?job-kind)
  (do
    (if (table-match occupation_shifts job ?job-kind)
        (then ?job-kind)
        (else default)): ?swh-key
    (bind 0 ?swh-top)
    (for-each-row occupation_shifts [/job ?swh-j] [/shift-id ?swh-sid]
      (if (and (= ?swh-j ?swh-key) (> ?swh-sid ?swh-top))
          (then (bind ?swh-sid ?swh-top))))
    (random-int 0 ?swh-top): ?swh-shift
    (for-each-row occupation_shifts
        [/job ?swh-j2] [/shift-id ?swh-sid2] [/day-label ?swh-day]
        [/start-h ?swh-start] [/end-h ?swh-end]
      (if (and (= ?swh-j2 ?swh-key) (= ?swh-sid2 ?swh-shift))
          (then (begin-belief {?job ?swh-day ?swh-start ?swh-end}))))))

(define-macro fire-self ()
  (for-each ?fire-jrel (every {@self job ?})
      (bind ?fire-jrel.target ?fire-job)
      (for-each ?fire-orel (every {?fire-job org ?})
          (bind ?fire-orel.target ?fire-org)
          (for-each ?fire-rrel (every {?fire-org employee-register ?})
              (bind ?fire-rrel.target ?fire-reg)
              (vacate-post ?fire-reg @self)))
      (end-belief ?fire-jrel)))
; ----------------------------------------------------------------------------
; THE ESTABLISHMENT - the org's POSTS, carried on its employee-register.
;
; A post is a LINE on the wage book. Its worker cell names the holder, and an EMPTY
; cell is what "vacant" means - the same shape the land registry uses for an unowned
; building (property-bootstrap files a title-deed with owner @nothing, and lists it
; for sale whether or not anyone has spoken for it). So the book shows the whole
; establishment, not just the manned half of it, and an officer learns of an opening
; by reading his own book rather than by consulting a config table he has no way of
; knowing.
;
; Only the STAFF establishment is filed here (org_staffing's staff-role x the authored
; headcount). A head is founded, never hired, so his line is appended when he seats.
; ----------------------------------------------------------------------------

; establish-posts - file the org's authored staff posts on a fresh register, all vacant.
(define-macro establish-posts (?reg ?org-kind)
  (if (table-match org_staffing org-kind ?org-kind staff-role ?ep-role)
    (then
      (bind 0 ?ep-line)
      (repeat (if (table-match public_orgs kind ?org-kind employee-count ?ep-n)
                  (then ?ep-n)
                  (else (k-default-staff-posts)))
        (do
          (bind (+ ?ep-line 1) ?ep-line)
          (table-add ?reg line ?ep-line worker @nothing job ?ep-role))))))

; fill-post - @self takes a job: his name goes into the vacant line's worker cell, IN
; PLACE. The line must not move - a job IS its line on this ledger, so striking and
; re-appending would hand the advertised job to a different line and the notice would
; never come down. No vacant line of that kind (a club membership, a job outside the
; establishment) -> nothing to fill, so a line is added, numbered after the last.
; Already on the book for it -> nothing to do (a second signing never duplicates a line).
(define-macro fill-post (?reg ?job-kind ?level)
  (if (not (table-match (attr ?reg writing) worker (name @self) job ?job-kind))
      (then
        (if (not (table-set ?reg (where worker @nothing job ?job-kind)
                                 worker (name @self) level ?level))
            (then
              (bind 0 ?fp-line)
              (for-each-row (attr ?reg writing) [/line ?fp-seen]
                (bind ?fp-seen ?fp-line))
              (table-add ?reg line (+ ?fp-line 1)
                              worker (name @self) job ?job-kind level ?level))))))

; vacate-post - a departure leaves the JOB behind: the worker's cell is emptied where it
; stands, keeping the line, its number and its job kind. Striking the line outright would
; retire the job along with the man, and the officer would never read an opening.
(define-macro vacate-post (?reg ?worker)
  (table-set ?reg (where worker (name ?worker)) worker @nothing level @nothing))
