; ----------------------------------------------------------------------------
; affair_rendezvous.hs - the lovers MEET (covert_affair_conduct_plan Phase 2).
;
; The `(generative-rendezvous)` flag dispatches to hse_engine.cc::
; run_generative_rendezvous, which (per lover-holding adult, monthly, after the
; same covert-affair gate as affair_correspondence):
;   1. picks a MODE from substrate affordances:
;        shared-hotel  - family_excursion: the married couple stays at the
;                        hotel (cover = the co-present spouse - zero deception
;                        substrate, the cheapest mode) and lover_shadows
;                        co-locates the paramour, gated on their attraction
;                        band + boldness. Risk = the spouse in the next room;
;                        residue = hotel_register entries for all three.
;        houseguest    - silent hours at the actor's own home. Risk = the
;                        household staff at the keyhole (dislike-scaled, the
;                        same hostile-servant lever as letter interception).
;        public crowd  - co-presence at a public venue (theatre / pub); an
;                        indiscretion plays out before the actor's circle
;                        (the Aintree pattern).
;   2. a tryst advances the affair (attraction nudge both sides) and may
;      hand-deliver a tryst_note naming the venue (the hand-to-hand channel -
;      no interception surface, but cache-able detective paper correlating
;      with the hotel_register),
;   3. every leak plants {cheater lover paramour} in a WITNESS; gossip + the
;      evidence-mediated discover_affair carry it to the betrayed spouse.
; Co-presence is registered with the activity-lanes machinery, so trysts also
; feed the incident pass and venue acquaintance-seeding like any other outing.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event affair_rendezvous
  (nl         "?actor steals away to meet a secret lover")
  (kind       _affair_rendezvous)
  (schedule   (monthly))
  (rng-stream incidents)
  (generative-rendezvous)

  (roles
    (role ?actor (template any_human)
                 (>= (years-old ?actor) 18)
                 (believes ?actor {@self lover ?}))))
