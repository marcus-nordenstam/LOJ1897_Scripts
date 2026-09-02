; ----------------------------------------------------------------------------
; org_staffing.hs - the staff occupation each org kind RECRUITS for, as authored
; config (a (define-table ...), like public_orgs / businesses / occupations).
; Loaded from historical/tables/ (directory-scanned) into the .hse catalog; read
; by the advertise task (advertise-task.hs) via (table-match org_staffing ...).
;
; WHY THIS TABLE: an org advertises the occupation it NEEDS - and ONLY that. The
; earlier advertise_post scored every hosted occupation a flat 1 and argmax-picked
; the first in occupations-table order; since the generic jobs (business-type
; none) are hosted by every org and `engineer` is the first of them, almost every
; org (bank, grocer, pub, registry, solicitor firm) advertised `engineer` - a
; post nobody was structured to fill, so jobseekers applied forever and were never
; hired. Each org now DISCLOSES its staff role here; there is no fallback.
;
;   org-kind    - the org kind, [k org <leaf>] (the KEY, matching the org kind the
;                 founding path resolves and advertise_post reads off the articles).
;   staff-role  - the occupation this org hires (the HEAD/owner is founded, never
;                 hired, so it is not listed): a scoped job kind [k job <leaf>]
;                 matching an occupations.hs row. One primary staff role per org
;                 (headcount lives in public_orgs employee-count); an org needing a
;                 second distinct role (restaurant cook, newspaper printer) is a
;                 future multi-role extension.
; ----------------------------------------------------------------------------

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
