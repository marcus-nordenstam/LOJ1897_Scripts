; ----------------------------------------------------------------------------
; landlord_estate - a landlord founds the estate that holds their rentals.
;
; The deferred half of the rental market's 2-phase vesting. The market (the C++
; run-housing-market / run-landlord-duties effects) now buys / lists a rental in
; the LANDLORD's own name - it no longer founds an estate org inline. This emergent
; per-NPC event closes the loop: a person who owns a building listed for lease but
; runs no `estate` yet founds one (the residential-letting company, seated in their
; home study) through found-org-seq, then reassigns every rental they own into it -
; so the rentals are the estate's business assets, inherited / dissolved with the
; estate by the ordinary org lifecycle rather than lumped with the person's home.
;
;   when : @self owns a rental - a building listed for lease OR rented out (a
;          DURABLE signal across the listed<->leased cycle) - AND has founded no
;          estate (landlord-needs-estate; self-terminating once the estate exists).
;   then : found-org-seq [k org estate] [k job landlord] (the landlord is its head)
;          + reassign-rentals-to-estate (vest the rentals into it).
;
; No C++ become_landlord / found_org_runtime / hire: founding runs through the same
; found-org-seq macro as every other org, in @self's own mind (@self IS the founder).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event landlord_estate
  (sim-window-start)
  (rng-stream business)

  (roles
    (role @self (template old_human)))

  (when (landlord-needs-estate @self))

  (effects
    (found-org-seq [k org estate] [k job landlord])
    (reassign-rentals-to-estate @self)))
