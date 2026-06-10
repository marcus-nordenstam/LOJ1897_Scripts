; ----------------------------------------------------------------------------
; affair_correspondence.hs - the letter channel of a covert affair
; (covert_affair_conduct_plan Phase 1 - the spine).
;
; The `(generative-correspondence)` flag dispatches to hse_engine.cc::
; run_generative_correspondence, which (per lover-holding adult, monthly):
;   1. confirms the affair is COVERT (a third-party lover, with at least one
;      side married - open courtships write no secret letters),
;   2. picks a CHANNEL from the sender's substrate affordances:
;        servant courier   - needs the sender's own household staff; the
;                            carrying servant is the interception surface
;        post, home-addr.  - always reachable (post office stands from 1700);
;                            the recipient household's mail-handler is the
;                            surface
;        poste-restante    - a false-name box; needs middle/upper standing;
;                            no surface until the alias is blown
;   3. rolls interception per the surface servant's dislike of the cheater
;      they serve (warmth stance band) - the Alice Yapp pattern: discovery
;      correlates with hostile-staff households, never a flat telepathic roll,
;   4. DELIVERED: the letter (writing = the affair fact {author lover
;      recipient}) is hidden in the recipient's hiding_spot cache - the
;      durable evidence trail (bounded per cache; later letters are burned),
;      INTERCEPTED: the letter surfaces in hostile hands, the interceptor
;      learns the affair and word is carried to the betrayed spouse; the
;      gossip cascade spreads it from there. crime_of_passion /
;      affair_fallout then consume the knowledge through the (now
;      evidence-mediated) discover_affair.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event affair_correspondence
  (nl         "?actor writes to a secret lover")
  (kind       _affair_correspondence)
  (schedule   (monthly))
  (rng-stream incidents)
  (generative-correspondence)

  (roles
    (role ?actor (template any_human)
                 (>= (years-old ?actor) 18)
                 (believes ?actor {@self lover ?}))))
