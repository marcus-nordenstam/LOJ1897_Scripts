; ----------------------------------------------------------------------------
; property_bootstrap.hs - the world-gen property + civic seed, authored as a MINDLESS
; (define-func) the engine invokes ONCE at bootstrap (call_hs_func, no actor - abs mind;
; @self would resolve to @fail, so this func never uses it).
;
;  (1) files a vacant title-deed (owner @nothing) per building - the land registry.
;  (2) builds the singleton for-sale-listings REGISTER ([building deed] rows, all vacant at
;      seed) the house-agency holds; seekers scan it, claim a row, and found on it.
;  (3) CHARTERS every org the town opens with - each public_orgs / cornerstone_businesses
;      kind - on a free building of its kind: articles + staff book, no head. An NPC founds
;      one by taking up its headless charter (found_public_org / found_cornerstone_business).
; Every org, bootstrapped or emergent, files its articles-of-incorporation on the company
; registry's incorporation-stack (see found-org-seq). Replaces the C++ hsim_bootstrap seed.
; ----------------------------------------------------------------------------

(define-func seed_property ()
  ; The singleton for-sale register, created once in the first building's room.
  (for-each ?b0 (env-entities [k building])
    (spatial ?b0 room /env): ?r0
    (if (and ?r0 (none (env-entities [k for-sale-listings])))
      (then
        (create-entity [k for-sale-listings] ?r0): ?reg0
        (table-init ?reg0 building deed)
        (break))))
  ; A vacant deed per building; list every one (all vacant at seed) in the register.
  (for-each ?b (env-entities [k building])
    (spatial ?b room /env): ?room
    (if ?room
      (then
        (create-entity [k title-deed] ?room): ?deed
        (table-init ?deed building owner)
        (table-add ?deed building ?b)
        (for-each ?reg (env-entities [k for-sale-listings])
          (table-add ?reg building ?b deed ?deed)))))
  ; Per-building MAIL PILES: the INCOMING pile letters are delivered to, and the OUTGOING
  ; pile a sender deposits into (the mail service drains it each morning and teleports each
  ; letter to the incoming pile of the address written on it). The ontology already declares
  ; outgoing-mail-stack as 'seeded at world setup' - nothing seeded either, so every
  ; (locate [k mail-stack] ..) searched a building, found nothing and concluded /fail, and
  ; read-mail could only ever end /fail: 0 successes town-wide over a 2yr run. That dead
  ; channel is what held the recruiting officer's office round to ONE round in two years -
  ; its gate re-arms on (days-since-last {@self read-mail ?wp /succ}), which never reset.
  (for-each ?mb (env-entities [k building])
    (spatial ?mb room /env): ?mroom
    (if ?mroom
      (then
        (create-entity [k mail-stack] ?mroom)
        (create-entity [k outgoing-mail-stack] ?mroom))))
  ; Every org the town OPENS WITH is CHARTERED here, ready to found: premises claimed off
  ; the register, articles filed on the incorporation stack, staff book created - and the
  ; founder cell left EMPTY. All of that is environment, which is why a mindless bootstrap
  ; can do it; the one thing it cannot write is a head, since heading an org is a mental
  ; act. Founding is then TAKING UP a headless charter (found_public_org /
  ; found_cornerstone_business): the town plans its institutions, an NPC steps into one.
  ; company-registry is chartered FIRST - its premises seat the incorporation stack every
  ; other charter is filed on.
  (charter-org [k org company-registry])
  (for-each-row public_orgs [/kind ?pk]
    [/charter-org ?pk])
  (for-each-row cornerstone_businesses [/kind ?ck]
    [/charter-org ?ck]))

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
      (if (table-match businesses org-kind ?kind building ?bk)
          (then ?bk) (else [k building office])): ?want-kind
      (for-each ?reg (env-entities [k for-sale-listings])
        (for-each-row (attr ?reg writing) [/building ?bldg]
          (if (is-a ?bldg ?want-kind)
            (then
              (spatial ?bldg room /env): ?croom
              (if (none (env-entities [k incorporation-stack]))
                (then (create-entity [k incorporation-stack] ?croom)))
              (create-entity [k articles-of-incorporation] ?croom): ?art
              (create-entity [k employee-register]         ?croom): ?creg
              (table-init ?creg worker job level)
              (establish-posts ?creg ?kind)
              (table-remove ?reg building ?bldg)
              (table-init ?art org-kind org_name founder workplace register)
              (table-match businesses org-kind ?kind name ?cname)
              (table-add ?art org-kind ?kind org_name ?cname founder @nothing
                              workplace ?bldg register ?creg)
              (head (env-entities [k incorporation-stack])): ?ist
              (if ?ist (then (push ?art ?ist)))
              (break))))))))
