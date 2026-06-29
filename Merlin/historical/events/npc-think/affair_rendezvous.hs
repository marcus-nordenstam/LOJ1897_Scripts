; ----------------------------------------------------------------------------
; affair_rendezvous (npc-think) - the lovers MEET (see Docs/hsim/hsim_social.md
; "Conduct channel 2: rendezvous"). The npc-think sibling of affair_correspondence
; (the letter channel): both are (generative-...) flag events that drive a covert
; affair forward; the located co-presence of the tryst is staged inside the C++
; pass (register_occupant), so the .hs is just the gate + flag.
;
; The `(generative-rendezvous)` flag dispatches to hse_engine.cc::
; run_generative_rendezvous, which (per lover-holding adult, monthly, after the
; same covert-affair gate as affair_correspondence):
;   1. picks a MODE from substrate affordances:
;        shared-hotel  - family_excursion: the married couple stays at the hotel
;                        (cover = the co-present spouse) and lover_shadows
;                        co-locates the paramour, gated on attraction + boldness.
;                        Risk = the spouse in the next room; residue =
;                        hotel_register entries for all three.
;        houseguest    - silent hours at the actor's own home. Risk = the
;                        household staff at the keyhole (dislike-scaled).
;        public crowd  - co-presence at a public venue (theatre / pub); an
;                        indiscretion plays out before the actor's circle.
;   2. a tryst advances the affair (attraction nudge both sides) and may
;      hand-deliver a tryst_note naming the venue (the hand-to-hand channel),
;   3. every leak plants {cheater lover paramour} in a WITNESS; gossip + the
;      evidence-mediated discover_affair carry it to the betrayed spouse.
; Co-presence is registered with the activity-lanes machinery, so trysts also
; feed the incident pass and venue acquaintance-seeding like any other outing.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event affair_rendezvous
  (rng-stream incidents)
  (generative-rendezvous)

  (roles
    ;; SELF-POV: @self gates on his OWN standing lover bond (self-read); the C++
    ;; generative pass stages the tryst's located co-presence via human channels,
    ;; never a mind peek.
    (role @self (template any_human)
                (believes {@self lover ?})))

  ;; moved from the @self role: the adult age gate is a non-belief attr-read,
  ;; so it lives in (when) rather than the belief-pure role.
  (when (>= (years-old @self) 18)))
