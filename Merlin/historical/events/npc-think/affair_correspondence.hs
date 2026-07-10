; ----------------------------------------------------------------------------
; affair_correspondence.hs - the letter channel of a covert affair
; (see Docs/hsim/hsim_social.md "Conduct channel 1: correspondence").
;
; PURE .hs (no C++ generator) - sibling of the other affair/motive events:
;   - ?paramour is the actor's first live third-party lover (a lover who is
;     not also a spouse - the actor's OWN beliefs, self-POV, no mind peek);
;   - (when ...) is the CONCEALMENT motive - an affair conducts itself
;     covertly only when discovery has a price: a married side, a betrothed
;     side (the engaged party's match is at stake), or a cross-class pairing
;     (the un-marriageable courtship whose exposure is the chastity /
;     standing scandal - the Smith shape). An open same-class courtship
;     between the unattached writes no secret letters. Plus the monthly
;     writer rate (0.5);
;   - (effects ...) composes the love letter - the writing IS the affair
;     fact {@i lover (o [n paramour])}, SIGNED (love letters carry their
;     author's name; reading one is discovering the affair) - and routes it
;     down the covert channel: servant courier / home-addressed post /
;     poste-restante, interception per the surface servant's dislike (the
;     Alice Yapp pattern), delivery into the recipient's hiding-spot cache
;     (the durable evidence trail). crime_of_passion / affair_fallout then
;     consume the knowledge through the evidence-mediated discover_affair.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour affair_correspondence
  (long-term-think)
  (rng-stream incidents)

  (roles
    (role @self (any_human @self)
                (believes {@self lover ?}))
    ; The paramour: a lover who is not also a spouse (the covert third party).
    (role ?paramour (any_human ?paramour)
      (believes {@self lover ?paramour})
      (not (believes {@self spouse ?paramour}))
      (pick-first-matching-role)))

  ; Adult floor, live paramour, the concealment motive (affair_macros.hs),
  ; the monthly rate.
  (when (and (>= (years-old @self) 18)
             (alive ?paramour)
             (covert-affair-motive ?paramour)
             (chance 0.5)))

  (effects
    (send-covert-letter ?paramour
                         (msg {@self lover ?paramour} signed)
                         [k love_letter])))
