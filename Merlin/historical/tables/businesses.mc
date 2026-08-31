; ----------------------------------------------------------------------------
; businesses.hs - premises metadata per org kind, as authored config (a
; (define-table ...), like cornerstone_businesses / public_orgs). Loaded from
; historical/tables/ into the .hse catalog; read by the org-founding path via
; hse_table_lookup (C++) - there is NO bespoke C++ parser or catalog struct.
;
; One row per foundable org kind:
;   org_kind          - the org kind, [k org <leaf>] (a disambiguated shorthand for the
;                       full org > com|gov|edu > ... path). The KEY, matching the org kind
;                       the founding path resolves. NOTE there is no `shop` org: shops are
;                       BUILDINGS; the retail ORGS (grocer / apothecary / bookseller /
;                       pawnbroker / antiques_shop) each seat in a shop building.
;   building          - the premises building kind, [k building <leaf>] (a commercial_building
;                       leaf); the pool is scanned for a free one of this kind at founding.
;   back_office_room  - the room LEAF that holds the org's records. A bare atom (DATA), not a
;                       [k ...] kind: some room leaves (`study`) are homonymous with a non-space
;                       kind, so the leaf name is the stable value (the reader scopes it to
;                       `interior_space <leaf>`).
;   premises          - on_site (spawn/acquire a building) or residence (run from the
;                       proprietor's home; the back_office_room is a room of his residence).
;
; An org kind NOT listed here defaults to (spatial office building) (back_office_room
; back_office) (premises on_site) - see building_kind_for_org / back_office_room_for /
; org_is_residence_seated.
; ----------------------------------------------------------------------------

(define-table businesses
  (fields name org_kind building back_office_room premises)

  ;; --- Industrial / financial: each needs its own building ---
  (record [n st-revier-mill]      [k org factory]         [k building factory]            back_office  on_site)
  (record [n meridian-bank]       [k org bank]            [k building bank]               back_office  on_site)
  (record [n the-christie-herald] [k org newspaper]       [k building newspaper]          back_office  on_site)

  ;; --- Retail ORGS (a customer-facing shop with a counter); records in the back office.
  ;;     Each is a real org kind; all seat in a `shop` building (there is no `shop` org). ---
  (record [n hallidays-grocery]   [k org grocer]          [k building shop]               back_office  on_site)
  (record [n quills-apothecary]   [k org apothecary]      [k building shop]               back_office  on_site)
  (record [n thornes-books]       [k org bookseller]      [k building shop]               back_office  on_site)
  (record [n goldmans-pledges]    [k org pawnbroker]      [k building shop]               back_office  on_site)
  (record [n the-curiosity-house] [k org antiques_shop]   [k building shop]               back_office  on_site)
  (record [n figaros]             [k org barbershop]      [k building barbershop]         back_office  on_site)

  ;; --- Hospitality / leisure: their own premises ---
  (record [n the-esplanade-hotel] [k org hotel]           [k building hotel]              back_office  on_site)
  (record [n the-copper-kettle]   [k org restaurant]      [k building restaurant]         back_office  on_site)
  (record [n the-anchor]          [k org pub]             [k building pub]                back_office  on_site)
  (record [n the-royal-theatre]   [k org theatre]         [k building theatre]            back_office  on_site)

  ;; --- Professional / agency: a general office building where clients call ---
  (record [n whitfield-and-crane] [k org solicitor_firm]  [k building office]             back_office  on_site)
  (record [n saltcombe-estates]   [k org house_agency]    [k building office]             back_office  on_site)
  (record [n albion-assurance]    [k org insurance_co]    [k building office]             back_office  on_site)
  (record [n mariner-shipping]    [k org shipping_agent]  [k building office]             back_office  on_site)

  ;; --- Clubs convene in their own clubhouse ---
  (record [n the-turf-club]       [k org race_club]       [k building athletic_clubhouse] back_office  on_site)
  (record [n the-corinthian-club] [k org athletic_club]   [k building athletic_clubhouse] back_office  on_site)
  (record [n the-albion-club]     [k org social_club]     [k building social_clubhouse]   back_office  on_site)

  ;; --- Public (gov / edu): premises kind declared for completeness ---
  (record [n st-clements-church]  [k org church]          [k building church]             back_office  on_site)
  (record [n st-marys-hospital]   [k org hospital]        [k building hospital]           back_office  on_site)
  (record [n christie-board-school] [k org state_school]  [k building school]             back_office  on_site)
  (record [n greyfriars-academy]  [k org private_school]  [k building school]             back_office  on_site)
  (record [n port-christie-college] [k org university]    [k building school]             back_office  on_site)

  ;; --- Public civic / cultural venues ---
  (record [n the-carnegie-library] [k org library]        [k building library]            back_office  on_site)
  (record [n the-christie-museum] [k org museum]          [k building museum]             back_office  on_site)
  (record [n the-assembly-rooms]  [k org meeting_hall]    [k building theatre]            back_office  on_site)
  (record [n victoria-park]       [k org sports_ground]   [k building sports_ground]      back_office  on_site)

  ;; --- Civic administration: registries and agencies, seated in general offices ---
  (record [n the-land-registry]   [k org land_registry]   [k building office]             back_office  on_site)
  (record [n companies-house]     [k org company_registry] [k building office]            back_office  on_site)

  ;; --- Residence-seated orgs: run from the proprietor's home study ---
  (record [n the-estate]          [k org estate]          [k building office]             study        residence)
  (record [n the-household]       [k org household]       [k building office]             study        residence))
