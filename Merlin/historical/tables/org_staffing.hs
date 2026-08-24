; ----------------------------------------------------------------------------
; org_staffing.hs - the staff occupation each org kind RECRUITS for, as authored
; config (a (define-table ...), like public_orgs / businesses / occupations).
; Loaded from historical/tables/ (directory-scanned) into the .hse catalog; read
; by advertise_post (recruit_think.hs) via (table-lookup org_staffing ...).
;
; WHY THIS TABLE: an org advertises the occupation it NEEDS - and ONLY that. The
; earlier advertise_post scored every hosted occupation a flat 1 and argmax-picked
; the first in occupations-table order; since the generic jobs (business_type
; none) are hosted by every org and `engineer` is the first of them, almost every
; org (bank, grocer, pub, registry, solicitor firm) advertised `engineer` - a
; post nobody was structured to fill, so jobseekers applied forever and were never
; hired. Each org now DISCLOSES its staff role here; there is no fallback.
;
;   org_kind    - the org kind, [k org <leaf>] (the KEY, matching the org kind the
;                 founding path resolves and advertise_post reads off the articles).
;   staff_role  - the occupation this org hires (the HEAD/owner is founded, never
;                 hired, so it is not listed): a scoped job kind [k job <leaf>]
;                 matching an occupations.hs row. One primary staff role per org
;                 (headcount lives in public_orgs employee_count); an org needing a
;                 second distinct role (restaurant cook, newspaper printer) is a
;                 future multi-role extension.
; ----------------------------------------------------------------------------

(define-table org_staffing
  (fields org_kind staff_role)

  ;; --- Civic (gov / edu / cultural): head is the superintendent/priest/principal
  (record [k org church]           [k job clerk])
  (record [k org hospital]         [k job nurse])
  (record [k org agency]           [k job clerk])
  (record [k org state_school]     [k job teacher])
  (record [k org private_school]   [k job teacher])
  (record [k org university]       [k job professor])
  (record [k org land_registry]    [k job clerk])
  (record [k org company_registry] [k job clerk])
  (record [k org library]          [k job clerk])
  (record [k org museum]           [k job clerk])
  (record [k org theatre]          [k job clerk])
  (record [k org meeting_hall]     [k job clerk])
  (record [k org sports_ground]    [k job gardener])

  ;; --- Financial / professional offices: the principals (banker / solicitor /
  ;;     agent) are may_own owners; the hired hands are clerks.
  (record [k org bank]             [k job clerk])
  (record [k org solicitor_firm]   [k job clerk])
  (record [k org house_agency]     [k job clerk])
  (record [k org insurance_co]     [k job clerk])
  (record [k org shipping_agent]   [k job clerk])

  ;; --- Industrial / press ---
  (record [k org factory]          [k job factory_worker])
  (record [k org newspaper]        [k job journalist])

  ;; --- Retail (proprietor owns; a shop_clerk mans the counter) ---
  (record [k org grocer]           [k job shop_clerk])
  (record [k org bookseller]       [k job shop_clerk])
  (record [k org pawnbroker]       [k job shop_clerk])
  (record [k org antiques_shop]    [k job shop_clerk])
  (record [k org apothecary]       [k job shop_clerk])
  (record [k org barbershop]       [k job barber])

  ;; --- Hospitality / leisure ---
  (record [k org restaurant]       [k job waiter])
  (record [k org pub]              [k job bartender])
  (record [k org hotel]            [k job maid])
  (record [k org race_club]        [k job jockey]))
