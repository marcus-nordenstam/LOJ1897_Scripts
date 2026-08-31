; ----------------------------------------------------------------------------
; property_bootstrap.hs - the world-gen property + civic seed, authored as a MINDLESS
; (define-func) the engine invokes ONCE at bootstrap (call_hs_func, no actor - abs mind;
; @self would resolve to @fail, so this func never uses it).
;
;  (1) files a vacant title_deed (owner @nothing) per building - the land registry.
;  (2) builds the singleton for_sale_listings REGISTER ([building deed] rows, all vacant at
;      seed) the house-agency holds; seekers scan it, claim a row, and found on it.
;  (3) founds the infrastructure orgs that have no proprietor (company_registry - the
;      companies house, holding the incorporation_stack every org's AOC is filed in - then
;      house_agency + land_registry), each on a free office building.
; Every org, bootstrapped or emergent, files its articles_of_incorporation on the company
; registry's incorporation_stack (see found-org-seq). Replaces the C++ hsim_bootstrap seed.
; ----------------------------------------------------------------------------

; The no-proprietor infrastructure orgs, founded in order (company_registry FIRST - it seats
; the incorporation stack the others file into).
(define-list infra_org_kinds
  [k org company_registry] [k org house_agency] [k org land_registry])

(define-func seed_property ()
  ; The singleton for-sale register, created once in the first building's room.
  (for-each ?b0 (env-entities [k building])
    (spatial ?b0 room /env): ?r0
    (if (and ?r0 (none (env-entities [k for_sale_listings])))
      (then
        (create-entity [k for_sale_listings] ?r0): ?reg0
        (table-init ?reg0 building deed)
        (break))))
  ; A vacant deed per building; list every one (all vacant at seed) in the register.
  (for-each ?b (env-entities [k building])
    (spatial ?b room /env): ?room
    (if ?room
      (then
        (create-entity [k title_deed] ?room): ?deed
        (table-init ?deed building owner)
        (table-add ?deed building ?b)
        (for-each ?reg (env-entities [k for_sale_listings])
          (table-add ?reg building ?b deed ?deed)))))
  ; The infrastructure orgs: for each kind, take the first FREE office off the register, mint
  ; its AOC + org object, and vest the premises deed in the ORG ITSELF (a government body owns
  ; its own seat). File the AOC on the incorporation stack (created the first time, in the
  ; company registry's room - the companies house).
  (for-each ?kind (list infra_org_kinds)
    (for-each ?reg (env-entities [k for_sale_listings])
      (for-each-row (attr ?reg writing) (building ?bldg) (deed ?deed)
        (if (is-a ?bldg [k building office])
          (then
            (spatial ?bldg room /env): ?iroom
            (if (none (env-entities [k incorporation_stack]))
              (then (create-entity [k incorporation_stack] ?iroom)))
            (create-entity [k articles_of_incorporation] ?iroom): ?art
            (o ?kind {?art declares_org @o}): ?org
            (table-set ?deed owner ?org)
            (table-remove ?reg building ?bldg)
            (table-init ?art org_kind org_name founder workplace register)
            (table-add ?art org_kind ?kind org_name @nothing founder @nothing
                            workplace ?bldg register @nothing)
            (head (env-entities [k incorporation_stack])): ?ist
            (if ?ist (then (push ?art ?ist)))
            (break)))))))
