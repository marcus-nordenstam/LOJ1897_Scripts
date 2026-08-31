; ----------------------------------------------------------------------------
; property_bootstrap.hs - the world-gen property + civic seed, authored as a MINDLESS
; (define-func) the engine invokes ONCE at bootstrap (call_hs_func, no actor - abs mind;
; @self would resolve to @fail, so this func never uses it).
;
;  (1) files a vacant title_deed (owner @nothing) per building - the land registry.
;  (2) builds the singleton for_sale_listings REGISTER ([building deed] rows, all vacant at
;      seed) the house-agency holds; seekers scan it, claim a row, and found on it.
;  (3) CHARTERS every org the town opens with - each public_orgs / cornerstone_businesses
;      kind - on a free building of its kind: articles + staff book, no head. An NPC founds
;      one by taking up its headless charter (found_public_org / found_cornerstone_business).
; Every org, bootstrapped or emergent, files its articles_of_incorporation on the company
; registry's incorporation_stack (see found-org-seq). Replaces the C++ hsim_bootstrap seed.
; ----------------------------------------------------------------------------

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
  ; Every org the town OPENS WITH is CHARTERED here, ready to found: premises claimed off
  ; the register, articles filed on the incorporation stack, staff book created - and the
  ; founder cell left EMPTY. All of that is environment, which is why a mindless bootstrap
  ; can do it; the one thing it cannot write is a head, since heading an org is a mental
  ; act. Founding is then TAKING UP a headless charter (found_public_org /
  ; found_cornerstone_business): the town plans its institutions, an NPC steps into one.
  ; company_registry is chartered FIRST - its premises seat the incorporation stack every
  ; other charter is filed on.
  (charter-org [k org company_registry])
  (for-each-row public_orgs (kind ?pk)
    (charter-org ?pk))
  (for-each-row cornerstone_businesses (kind ?ck)
    (charter-org ?ck)))

; charter-org - file one org's charter on a free building of its kind. A no-op if the town
; already holds a charter of this kind (the census counts charters, headed or not, so a kind
; is chartered once) or if no free building of the right kind is left on the register. The
; deed stays UNOWNED: taking a post is not buying the premises, and pulling the row off the
; register is what stops anyone else claiming them.
;
; A MACRO, not a func: it WRITES the environment, and a define-func called from .hs must be
; pure (see the value-func-purity lint).
(define-macro charter-org (?kind)
  (if (= (count-orgs-isa ?kind) 0)
    (then
      (if (table-match businesses org_kind ?kind building ?bk)
          (then ?bk) (else [k building office])): ?want-kind
      (for-each ?reg (env-entities [k for_sale_listings])
        (for-each-row (attr ?reg writing) (building ?bldg)
          (if (is-a ?bldg ?want-kind)
            (then
              (spatial ?bldg room /env): ?croom
              (if (none (env-entities [k incorporation_stack]))
                (then (create-entity [k incorporation_stack] ?croom)))
              (create-entity [k articles_of_incorporation] ?croom): ?art
              (create-entity [k employee_register]         ?croom): ?creg
              (table-init ?creg worker job level)
              (table-remove ?reg building ?bldg)
              (table-init ?art org_kind org_name founder workplace register)
              (table-match businesses org_kind ?kind name ?cname)
              (table-add ?art org_kind ?kind org_name ?cname founder @nothing
                              workplace ?bldg register ?creg)
              (head (env-entities [k incorporation_stack])): ?ist
              (if ?ist (then (push ?art ?ist)))
              (break))))))))
