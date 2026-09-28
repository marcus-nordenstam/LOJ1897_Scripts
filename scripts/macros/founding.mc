; ----------------------------------------------------------------------------
; founding.mc - the org-founding belief sequence, as atomic .mc ops.
;
; This is the DECOMPOSITION of the old monolithic C++ (found-org) effect: the documents +
; every belief the FOUNDER/head holds are minted here, in the .mc DSL. Premises are claimed
; off the land registry (found-org-seq scans the title_deeds for a vacant one of the org's
; building kind and stamps @self as its owner), not acquired from a C++ pool. The one op still
; reaching outside @self's mind is:
;   (stamp-work-hours ...) - the shift stamp, reading the occupation_shifts table for the job.
;
; STAFFING is NOT done here. A new org is founded with its HEAD only; the emergent
; labour market staffs it over subsequent ticks: the recruit-staff duty-holder posts
; a parish-board advert (recruit_think.mc), jobless seekers read the board and apply
; in person (job_search_think.mc), the recruiter decides over his applicants book,
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

; org_staffing - the staff occupation each org kind RECRUITS for, read below when
; an org files its staff establishment. An org advertises the occupation it NEEDS
; and ONLY that: each org discloses its staff role here, and there is no fallback.
;
;   org-kind    - the org kind, [k org <leaf>] (the KEY, matching the org kind the
;                 founding path resolves).
;   staff-role  - the occupation this org hires (the HEAD/owner is founded, never
;                 hired, so it is not listed): a scoped job kind [k job <leaf>]
;                 matching an occupations.mc row. One primary staff role per org
;                 (headcount lives in public_orgs employee-count); an org needing a
;                 second distinct role (restaurant cook, newspaper printer) is a
;                 future multi-role extension.
(define-table org_staffing
  (fields org-kind staff-role)

  ;; --- Civic (gov / edu / cultural): head is the superintendent/priest/principal
  (record [k org church]           [k job clerk])
  (record [k org hospital]         [k job nurse])
  (record [k org agency]           [k job clerk])
  (record [k org state-school]     [k job teacher])
  (record [k org private-school]   [k job teacher])
  (record [k org university]       [k job professor])
  (record [k org land-registry]    [k job clerk])
  (record [k org company-registry] [k job clerk])
  (record [k org library]          [k job clerk])
  (record [k org museum]           [k job clerk])
  (record [k org theatre]          [k job clerk])
  (record [k org meeting-hall]     [k job clerk])
  (record [k org sports-ground]    [k job gardener])

  ;; --- Financial / professional offices: the principals (banker / solicitor /
  ;;     agent) are may-own owners; the hired hands are clerks.
  (record [k org bank]             [k job clerk])
  (record [k org solicitor-firm]   [k job clerk])
  (record [k org house-agency]     [k job clerk])
  (record [k org insurance-co]     [k job clerk])
  (record [k org shipping-agent]   [k job clerk])

  ;; --- Industrial / press ---
  (record [k org factory]          [k job factory-worker])
  (record [k org newspaper]        [k job journalist])

  ;; --- Retail (proprietor owns; a shop-clerk mans the counter) ---
  (record [k org grocer]           [k job shop-clerk])
  (record [k org bookseller]       [k job shop-clerk])
  (record [k org pawnbroker]       [k job shop-clerk])
  (record [k org antiques-shop]    [k job shop-clerk])
  (record [k org apothecary]       [k job shop-clerk])
  (record [k org barbershop]       [k job barber])

  ;; --- Hospitality / leisure ---
  (record [k org restaurant]       [k job waiter])
  (record [k org pub]              [k job bartender])
  (record [k org hotel]            [k job maid])
  (record [k org race-club]        [k job jockey]))



; found-org-seq - read the house-agency's for-sale REGISTER for a premises of the org's
; building kind (businesses-table `building`, unlisted -> office), claim it, and found the
; org on it. Scanning the compressed register table (not the whole deed registry) is the
; knowledge channel: the founder consults the published listings, claims the first row of
; the right kind (table-set the deed's owner + drop the row), and founds. No such row ->
; NOTHING is minted (no malformed org, no error).
; DORMANT - this lane never ran; revived on the form deeds / articles with its own gauntlet.
;(define-macro found-org-seq (?org-kind ?head-role)
;  (do
;    (free-premises-for ?org-kind): ?wp
;    (if (substantial ?wp)
;      (then
;        ; CLAIM: stamp @self as the premises' owner + pull the row off the register.
;        (claim-deed ?wp)
;        (delist ?wp)
;        (take-premises ?wp)
;        ; The org's documents (articles + an empty register), seeded in a room (a
;        ; document must live in a SPACE, never at the building).
;        (spatial ?wp room): ?back
;        (check ?back)
;        (create-entity [k articles-of-incorporation] ?back): ?art
;        (create-entity [k employee-register]         ?back): ?reg
;        (establish-posts ?reg ?org-kind)
;        ; The articles DOCUMENT the org into being: a one-row TABLE of its constitutive
;        ; cells. This is the whole ENVIRONMENT half of founding - the org has no other
;        ; objective existence.
;        (table-match businesses org-kind ?org-kind name ?org-name)
;        (file-articles ?art ?org-kind ?org-name (name @self) ?wp ?reg)
;        (name-premises ?wp ?org-kind ?org-name)
;        (seat-org-head ?art ?wp ?reg ?head-role)))))

; List building ?b, by its address, on every for-sale listing - a building the land registry
; holds a deed for.
; DORMANT - this lane never ran; revived on the form deeds / articles with its own gauntlet.
;(define-macro list-for-sale (?b)
;  (if (substantial (title-deed-of ?b))
;    (then
;      (for-each ?listings (env-entities [k for-sale-listings])
;        (table-add ?listings building (attr ?b address))))))


; claim-deed ?b - @self's name goes on the land registry's deed for building ?b.
; DORMANT - this lane never ran; revived on the form deeds / articles with its own gauntlet.
;(define-macro claim-deed (?b)
;  (do
;    (title-deed-of ?b): ?cd-deed
;    (check (substantial ?cd-deed))
;    (table-set ?cd-deed owner (name @self))))




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

; DORMANT - this lane never ran; revived on the form deeds / articles with its own gauntlet.
;(define-macro found-club-seq (?club-kind)
;  (do
;    (free-premises-for ?club-kind): ?wp
;    (if (substantial ?wp)
;      (then
;        (claim-deed ?wp)
;        (delist ?wp)
;        (for-each ?room (spatial ?wp parts [k interior-space room] /env)
;            (spatial-write ?room struct_parent ?wp))
;        (spatial ?wp room): ?back
;        (check ?back)
;        (create-entity [k articles-of-incorporation] ?back): ?art
;        (create-entity [k membership-roll]           ?back): ?roll
;        (table-init ?roll member joined-date)
;        (o ?club-kind {?art declares-org @o}): ?org
;        (table-match businesses org-kind ?club-kind name ?org-name)
;        (begin-belief {?org isa ?club-kind})
;        (begin-belief {?org founder @self})
;        (begin-belief {?org workplace ?wp})
;        (begin-belief {?org name ?org-name})
;        (begin-belief {?org record ?art})
;        (begin-belief {?org membership-roll ?roll})
;        (file-articles ?art ?club-kind ?org-name (name @self) ?wp ?roll)
;        (name-premises ?wp ?club-kind ?org-name)
;        ; The founder is the club's first MEMBER - a row on the roll, not a seat on
;        ; an establishment: a club has members, never posts.
;        (table-add ?roll member (name @self) joined-date (time date))
;        (begin-belief {@self member-of ?org})))))

; ----------------------------------------------------------------------------
; hire-beliefs - the BELIEF-ONLY half of hiring (no roster write).
;
; Reads the org's kind + premises off the existing articles and mints every
; employment belief in @self's mind. It does NOT touch the roster - the worker is
; rostered separately: hire-seq (below) writes the register itself for an emergent
; hire, while the C++ candidate-scan effects (bootstrap / staff-household / jockey)
; roster the worker via the thin enrol verb and let the materialize_employment
; rule call THIS to mint the beliefs. So the beliefs live in .mc; the roster
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
; DORMANT - this lane never ran; revived on the form deeds / articles with its own gauntlet.
;(define-macro employ-beliefs (?org ?wp ?job-kind ?level ?reg)
;  (do
;    (begin-belief {?wp occupant @self})
;    (for-each ?room (spatial ?wp parts [k interior-space room] /env)
;        (spatial-write ?room struct_parent ?wp))
;    (table-match income_by_level level ?level income ?salary)
;    (if (table-match (attr ?reg writing) worker (name @self) job ?job-kind job-id ?eb-line
;                                          shift ?eb-shift)
;        (then
;          (o ?job-kind {@o org ?org} {@o job-id ?eb-line}): ?job
;          (begin-belief {?job org ?org})
;          (begin-belief {?job job-id ?eb-line})
;          (begin-belief {@self job ?job})
;          (begin-belief {?job level ?level})
;          (begin-belief {?job salary ?salary})
;          (begin-belief {?job since (time year)})
;          (stamp-shift-hours ?job ?job-kind ?eb-shift)))))

; DORMANT - this lane never ran; revived on the form deeds / articles with its own gauntlet.
;(define-macro hire-beliefs (?art ?job-kind ?level)
;  (do
;    ; --- learn the org off the articles: a new hire READs the incorporation page.
;    ; adopt-aoc decodes the AOC table into the org object + its constitutive beliefs
;    ; ({?art declares-org ?org} / {?org isa} / {?org workplace} / {?org employee-register}).
;    (adopt-aoc ?art)
;    ; --- @self's mind: recall the org just learned (anchored to the articles) + its
;    ; premises, then mint the employment beliefs.
;    (o {?art declares-org @o}): ?org
;    ; (any ..).target, not a bare {?org workplace ?wp}: a bare pattern standing as an effect
;    ; STATEMENT computes a clause and throws it away - it binds nothing, however plainly it
;    ; reads as a recall. The workplace adopt-aoc has just minted was arriving unbound here,
;    ; and {@fail occupant @self} went in after it.
;    (any {?org workplace ?}).target: ?wp
;    (any {?org employee-register ?}).target: ?hb-reg
;    (employ-beliefs ?org ?wp ?job-kind ?level ?hb-reg)))


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
; DORMANT - this lane never ran; revived on the form deeds / articles with its own gauntlet.
;(define-macro hire-seq (?art ?job-kind ?level)
;  (do
;    ; --- the register and premises the articles name, found where they stand: @self is at
;    ; the premises and signs the book in hand, so he sees it before learning the org.
;    (articles-register ?art): ?reg
;    (articles-premises ?art): ?wp
;    (check (substantial ?reg))
;    (observe ?reg)
;    (adopt-aoc ?art)
;    (o {?art declares-org @o}): ?org
;    ; --- env-side roster (abs): record @self under the matched job kind + rank.
;    (fill-post ?reg ?job-kind ?level)
;    ; --- the employment beliefs in @self's mind, off the line he now holds.
;    (employ-beliefs ?org ?wp ?job-kind ?level ?reg)))

; ----------------------------------------------------------------------------
; fire-self - a worker leaves his OWN post. Scrubs @self's row off the firm's
; employee-register (a public doc, keyed on him via (find worker (name @self))) and
; ends his OWN {@self job} belief (its org / salary / level decorations go with
; it). The register is reached by @self's own forward belief walk: {@self job.org}
; -> {org record} -> the articles' `register` field. Every step is @self / a
; public doc - no cross-mind write. (A boss firing SOMEONE ELSE cannot end their
; beliefs; the sacked worker reconciles his own stale row.)
; ----------------------------------------------------------------------------




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
;
; ONE LINE CARRIES THE WHOLE POST. Everything an officer must know about a seat sits on
; its own row, so he reads it off the page instead of remembering it: who holds it and
; since when, whether a promise is outstanding and to whom and since when, and whether a
; notice for it stands. That is what makes the book - not any one officer's memory - the
; authority: a second man taking the duty reads the same facts, and nothing is lost when
; the first forgets or dies. The dates are DATE symbols ((time date)); elapsed time comes
; from (abs-seconds ?cell), the same composition every other recency test uses.
; ----------------------------------------------------------------------------



