; ----------------------------------------------------------------------------
; businesses.mc - premises metadata per org kind, as authored config (a
; (define-table ...), like cornerstone_businesses / public_orgs). Loaded from
; tables/ into the .mc catalog; read by the org-founding path via
; hse_table_lookup (C++) - there is NO bespoke C++ parser or catalog struct.
;
; One row per foundable org kind:
;   org-kind          - the org kind, [k org <leaf>] (a disambiguated shorthand for the
;                       full org > com|gov|edu > ... path). The KEY, matching the org kind
;                       the founding path resolves. NOTE there is no `shop` org: shops are
;                       BUILDINGS; the retail ORGS (grocer / apothecary / bookseller /
;                       pawnbroker / antiques-shop) each seat in a shop building.
;   building          - the premises building kind, [k building <leaf>] (a commercial-building
;                       leaf); the pool is scanned for a free one of this kind at founding.
;   back-office-room  - the room LEAF that holds the org's records. A bare atom (DATA), not a
;                       [k ...] kind: some room leaves (`study`) are homonymous with a non-space
;                       kind, so the leaf name is the stable value (the reader scopes it to
;                       `interior-space <leaf>`).
;   premises          - on_site (spawn/acquire a building) or residence (run from the
;                       proprietor's home; the back-office-room is a room of his residence).
;   occupancy         - whole: the org takes the whole building; shared: it takes a
;                       sub-premise (a floor / suite) and other orgs may share the building.
;   names-building    - yes: the org NAMES its premises after itself (the building's `name`
;                       becomes the org's name, and a name-sign goes up) - a pub, a factory,
;                       a hotel. no: the building keeps its address as its only identity.
;                       Independent of occupancy: Companies House takes a whole office and
;                       still leaves it "14 Compton Ave". A building name is durable - the
;                       first namer wins and a later tenant works at that name.
;
; An org kind NOT listed here defaults to (spatial office building) (back-office-room
; back-office) (premises on_site) - see building_kind_for_org / back_office_room_for /
; org_is_residence_seated.
; ----------------------------------------------------------------------------

(define-table businesses
  (fields name org-kind building back-office-room premises occupancy names-building)

  ;; --- Industrial / financial: each needs its own building ---
  (record [n st-revier-mill]      [k factory-org]         [k factory-building]            back-office  on_site   whole  yes)
  (record [n meridian-bank]       [k bank-org]            [k bank-building]               back-office  on_site   whole  yes)
  (record [n the-christie-herald] [k newspaper-org]       [k newspaper-building]          back-office  on_site   whole  yes)

  ;; --- Retail ORGS (a customer-facing shop with a counter); records in the back office.
  ;;     Each is a real org kind; all seat in a `shop` building (there is no `shop` org). ---
  (record [n hallidays-grocery]   [k grocer]          [k shop]               back-office  on_site   whole  yes)
  (record [n quills-apothecary]   [k apothecary-org]      [k shop]               back-office  on_site   whole  yes)
  (record [n thornes-books]       [k bookseller]      [k shop]               back-office  on_site   whole  yes)
  (record [n goldmans-pledges]    [k pawnbroker]      [k shop]               back-office  on_site   whole  yes)
  (record [n the-curiosity-house] [k antiques-shop]   [k shop]               back-office  on_site   whole  yes)
  (record [n figaros]             [k barbershop-org]      [k barbershop-building]         back-office  on_site   whole  yes)

  ;; --- Hospitality / leisure: their own premises ---
  (record [n the-esplanade-hotel] [k hotel-org]           [k hotel-building]              back-office  on_site   whole  yes)
  (record [n the-copper-kettle]   [k restaurant-org]      [k restaurant-building]         back-office  on_site   whole  yes)
  (record [n the-anchor]          [k pub-org]             [k pub-building]                back-office  on_site   whole  yes)
  (record [n the-royal-theatre]   [k theatre-org]         [k theatre-building]            back-office  on_site   whole  yes)

  ;; --- Professional / agency: a general office building where clients call ---
  (record [n whitfield-and-crane] [k solicitor-firm]  [k office]             back-office  on_site   whole yes)
  (record [n saltcombe-estates]   [k house-agency]    [k office]             back-office  on_site   whole yes)
  (record [n albion-assurance]    [k insurance-co]    [k office]             back-office  on_site   whole yes)
  (record [n mariner-shipping]    [k shipping-agent]  [k office]             back-office  on_site   whole yes)

  ;; --- Clubs convene in their own clubhouse ---
  (record [n the-turf-club]       [k race-club]       [k athletic-clubhouse] back-office  on_site   whole  yes)
  (record [n the-corinthian-club] [k athletic-club]   [k athletic-clubhouse] back-office  on_site   whole  yes)
  (record [n the-albion-club]     [k social-club]     [k social-clubhouse]   back-office  on_site   whole  yes)

  ;; --- Public (gov / edu): premises kind declared for completeness ---
  (record [n st-clements-church]  [k church-org]          [k church-building]             back-office  on_site   whole  yes)
  (record [n st-marys-hospital]   [k hospital-org]        [k hospital-building]           back-office  on_site   whole  yes)
  (record [n christie-board-school] [k state-school]  [k school]             back-office  on_site   whole  yes)
  (record [n greyfriars-academy]  [k private-school]  [k school]             back-office  on_site   whole  yes)
  (record [n port-christie-college] [k university]    [k school]             back-office  on_site   whole  yes)

  ;; --- Public civic / cultural venues ---
  (record [n the-carnegie-library] [k library-org]        [k library-building]            back-office  on_site   whole  yes)
  (record [n the-christie-museum] [k museum-org]          [k museum-building]             back-office  on_site   whole  yes)
  (record [n the-assembly-rooms]  [k meeting-hall-org]    [k theatre-building]            back-office  on_site   whole  yes)
  (record [n victoria-park]       [k sports-ground-org]   [k sports-ground-building]      back-office  on_site   whole  yes)

  ;; --- Civic administration: registries and agencies, seated in general offices ---
  (record [n the-land-registry]   [k land-registry]   [k office]             back-office  on_site   whole  yes)
  (record [n companies-house]     [k company-registry] [k office]            back-office  on_site   whole  yes)

  ;; --- Residence-seated orgs: run from the proprietor's home study ---
  (record [n the-estate]          [k estate]          [k office]             study        residence shared no)
  (record [n the-household]       [k household]       [k office]             study        residence shared no))
