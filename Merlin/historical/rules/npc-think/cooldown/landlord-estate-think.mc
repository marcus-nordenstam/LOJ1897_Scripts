; ----------------------------------------------------------------------------
; landlord_estate - a landlord founds the estate that holds their rentals.
;
; The deferred half of the rental market's 2-phase vesting. The market (the C++
; run-housing-market / run-landlord-duties effects) buys / lists a rental in
; the LANDLORD's own name. This emergent per-NPC rule closes the loop: a person
; who holds a rental but runs no `estate` yet founds one (the residential-letting
; company, seated in their home study) through found-org-seq, then reassigns
; every rental they own into it - so the rentals are the estate's business
; assets, inherited / dissolved with the estate by the ordinary org lifecycle
; rather than lumped with the person's home.
;
; The rental is recognised purely from @self's OWN beliefs (object-cache role,
; no entity scan):
;   {@self own ?rental}                  the deed knowledge (register_ownership)
;   {?rental availability [k for-rent]}  advertised to let    (list_for_lease)
;   {?rental tenant ?}                   rented out (execute_lease, lessor side)
; listed OR leased = the DURABLE rental signal across the listed<->leased cycle;
; an owner-occupied home matches neither. The (when) re-checks per candidate, so
; a multi-rental owner founds ONE estate on the first candidate (which vests ALL
; rentals) and the remaining candidates gate out on the job.org-belief throttle.
;
;   when : @self runs no estate yet (runs-org; self-terminating - founding mints
;          the {@self job.org <estate>} belief runs-org reads).
;   then : found-org-seq [k org estate] [k job landlord] (the landlord is its head)
;          + reassign-rentals-to-estate (vest the rentals into it).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think landlord_estate
  (cooldown 1 m)
  (rng-stream business)

  ; THE FOUNDING CAP as a CACHED self-gate filter: an NPC heads at most ONE
  ; non-household org, and an estate IS one - so a man already heading ANY
  ; business / public org / estate founds no estate (subsumes the old
  ; estate-only throttle; permanent-kind match, decay-proof).
  (role @self (old_human @self)
              -{@self job [k head-of-non-household-org]})
  (role ?rental {@self own ?rental}
                (or {?rental availability [k for-rent]}
                    {?rental tenant ?}))

  (effects
    (found-org-seq [k org estate] [k job landlord])
    ; Vest every rental @self owns into the estate he just founded: re-point the
    ; deed's owner to the estate's articles and drop his own {own} - the ESTATE owns
    ; it now (inherited / dissolved with the estate, not lumped with his home). The
    ; estate is his articles that is-a estate (founder @self); a public-doc scan + his
    ; own belief drop, no cross-mind write. An owner-occupied home matches neither
    ; rental signal, so it is left his.
    (for-each ?ea (env-entities [k articles-of-incorporation])
      (do
        (o {?ea declares-org @o}): ?org
        (any {?org isa ?ok})
        (any {?org founder ?f})
        (if (and (= ?f @self) (is-a ?ok [k org estate]))
          (then
            (for-each ?deed (env-entities [k title-deed])
              (do
                (table-match (attr ?deed writing) owner ?o building ?b)
                (if (and (= ?o @self)
                         (or {?b availability [k for-rent]} {?b tenant ?}))
                  (then
                    (table-set ?deed owner ?ea)
                    (end-belief {@self own ?b})))))
            (break)))))))
