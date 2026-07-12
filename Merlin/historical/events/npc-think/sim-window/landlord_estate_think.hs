; ----------------------------------------------------------------------------
; landlord_estate - a landlord founds the estate that holds their rentals.
;
; The deferred half of the rental market's 2-phase vesting. The market (the C++
; run-housing-market / run-landlord-duties effects) buys / lists a rental in
; the LANDLORD's own name. This emergent per-NPC event closes the loop: a person
; who holds a rental but runs no `estate` yet founds one (the residential-letting
; company, seated in their home study) through found-org-seq, then reassigns
; every rental they own into it - so the rentals are the estate's business
; assets, inherited / dissolved with the estate by the ordinary org lifecycle
; rather than lumped with the person's home.
;
; The rental is recognised purely from @self's OWN beliefs (object-cache role,
; no entity scan):
;   {@self own ?rental}                  the deed knowledge (register_ownership)
;   {?rental availability [k for_rent]}  advertised to let    (list_for_lease)
;   {?rental tenant ?}                   rented out (execute_lease, lessor side)
; listed OR leased = the DURABLE rental signal across the listed<->leased cycle;
; an owner-occupied home matches neither. The (when) re-checks per candidate, so
; a multi-rental owner founds ONE estate on the first candidate (which vests ALL
; rentals) and the remaining candidates gate out on the employer-belief throttle.
;
;   when : @self runs no estate yet (runs-org; self-terminating - founding mints
;          the {@self employer <estate>} belief runs-org reads).
;   then : found-org-seq [k org estate] [k job landlord] (the landlord is its head)
;          + reassign-rentals-to-estate (vest the rentals into it).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think landlord_estate
  (sim-window-think)
  (rng-stream business)

  (role @self (old_human @self))
  (role ?rental (believes {@self own ?rental})
                (or (believes {?rental availability [k for_rent]})
                    (believes {?rental tenant ?})))

  ; Self-throttle: already running an estate = the actor's own ongoing
  ; {@self employer <org>} belief whose org object is-a estate (the same walk
  ; the retired runs-org op did).
  (when (not (believes-obj-kind employer [k org estate])))

  (cont-fire-effects
    (found-org-seq [k org estate] [k job landlord])
    (reassign-rentals-to-estate @self)))
