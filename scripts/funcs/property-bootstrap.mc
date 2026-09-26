; ----------------------------------------------------------------------------
; property_bootstrap.mc - the world-gen property + civic seed, authored as a MINDLESS
; (define-func) town-startup calls ONCE, mindless (no actor - abs mind;
; @self would resolve to @fail, so this func never uses it).
;
;  (1) builds the singleton for-sale-listings REGISTER (one [building] row per premises,
;      all vacant at seed) the house-agency holds. A record names a building by its
;      address and a person by his name, never by an object: the page outlives the thing.
;  (2) CHARTERS every org the town opens with - each public_orgs / cornerstone_businesses
;      kind - on a free building of its kind: articles + staff book, no owner. A founder
;      takes one up at world-gen (seat-founding-heads).
;  (3) files a title deed per building, owned by nobody, on the land registry's stack.
; Every org files its articles-of-incorporation on the company registry's incorporation-stack.
; ----------------------------------------------------------------------------

(define-func seed_property ()
  ; The singleton for-sale register, created once in the first building's room.
  (for-each ?b0 (env-entities [k building])
    (spatial ?b0 room /env): ?r0
    (if (and ?r0 (none (env-entities [k for-sale-listings])))
      (then
        (create-entity [k for-sale-listings] ?r0): ?reg0
        (table-init ?reg0 building)
        (break))))
  ; Every premises is on the market at seed.
  (for-each ?b (env-entities [k building])
    (spatial ?b room /env): ?room
    (if ?room
      (then
        (for-each ?reg (env-entities [k for-sale-listings])
          (table-add ?reg building (attr ?b address))))))
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
  ; ADDRESS-SIGNS: every addressed building shows its address, as a fixture of the building
  ; (perceived with it). The address is the premises' identity when it has no name, and the
  ; sign is what lets an NPC carrying a written address recognise he has arrived. A
  ; building the numbering pass could not address gets no sign - there is nothing to show.
  (for-each ?ab (env-entities [k building])
    (attr ?ab address): ?aaddr
    (if (substantial ?aaddr)
      (then
        (create-entity [k address-sign] @nothing ?ab): ?asign
        (set-attr ?asign address ?aaddr))))
  ; Every org the town OPENS WITH is CHARTERED here: premises claimed off the register,
  ; articles filed on the incorporation stack, staff book created - and no owner entry. A
  ; founder steps into one at world-gen once minds are live (seat-founding-heads).
  ; company-registry is chartered FIRST - its premises seat the incorporation stack every
  ; other charter is filed on.
  (charter-org [k org company-registry])
  (for-each-row public_orgs [/kind ?pk]
    (charter-org ?pk))
  (for-each-row cornerstone_businesses [/kind ?ck]
    (charter-org ?ck))
  (seed-land-registry))

; charter-org - file one org's charter on a free building of its kind. A no-op if the town
; already holds a charter of this kind (the census counts charters, headed or not, so a kind
; is chartered once) or if no free building of the right kind is left on the register. The
; deed stays UNOWNED: taking a post is not buying the premises, and pulling the row off the
; register is what stops anyone else claiming them.
(define-func charter-org (?kind)
  (if (= (count-orgs-isa ?kind) 0)
    (then
      (free-premises-for ?kind): ?bldg
      (if (substantial ?bldg)
        (then
          (spatial ?bldg room /env): ?croom
          (if (none (env-entities [k incorporation-stack]))
            (then (create-entity [k incorporation-stack] ?croom)))
          (create-entity [k articles-of-incorporation] ?croom): ?art
          (create-entity [k employee-register]         ?croom): ?creg
          (establish-posts ?creg ?kind)
          (delist ?bldg)
          (table-match businesses org-kind ?kind name ?cname)
          (file-articles ?art ?kind ?cname ?bldg ?creg)
          (name-premises ?bldg ?kind ?cname))))))

; free-premises-for ?org-kind - the first building on the for-sale register of the premises
; kind the businesses table gives ?org-kind (an office when it names none), or @nothing.
(define-func free-premises-for (?org-kind)
  (if (table-match businesses org-kind ?org-kind building ?fp-bk)
      (then ?fp-bk) (else [k building office])): ?fp-kind
  (bind @nothing ?found)
  (for-each ?fp-reg (env-entities [k for-sale-listings])
    (for-each ?fp-b (env-entities ?fp-kind)
      (if (table-match (attr ?fp-reg writing) building (attr ?fp-b address))
        (then
          (bind ?fp-b ?found)
          (break)))))
  ?found)

; seed-land-registry - a title deed per building, owned by nobody, filed on a title-deed stack
; in the land registry's premises.
(define-func seed-land-registry ()
  (headless-charter [k org land-registry]): ?slr-art
  (check (substantial ?slr-art))
  (spatial (articles-premises ?slr-art) room /env): ?slr-room
  (create-entity [k title-deed-stack] ?slr-room): ?slr-stack
  (for-each ?b (env-entities [k building])
    (attr ?b address): ?slr-addr
    (create-entity [k title-deed] ?slr-room): ?slr-deed
    (set-writing ?slr-deed (table-msg title_deed_form [[building ?slr-addr]]))
    (push ?slr-deed ?slr-stack)))
