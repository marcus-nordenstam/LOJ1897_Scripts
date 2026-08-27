; ----------------------------------------------------------------------------
; affair_correspondence.hs - the letter channel of a covert affair
; (see Docs/hsim/hsim_social.md "Conduct channel 1: correspondence").
;
; PURE .hs (no C++ generator) - sibling of the other affair/motive rules:
;   - ?paramour is the actor's first live third-party lover (a lover who is
;     not also a spouse - the actor's OWN beliefs, self-POV, no mind peek);
;   - the CONCEALMENT motive is the ?paramour role's (covert-affair-motive)
;     filter - an affair conducts itself covertly only when discovery has a
;     price: a married side, a betrothed side (the engaged party's match is at
;     stake), or a cross-class pairing (the un-marriageable courtship whose
;     exposure is the chastity / standing scandal - the Smith shape). An open
;     same-class courtship between the unattached writes no secret letters.
;     (when ...) is the monthly writer rate (0.5);
;   - (effects ...) composes the love letter - the writing IS the affair
;     fact {@i lover (o [n paramour])}, SIGNED (love letters carry their
;     author's name; reading one is discovering the affair) - and routes it
;     down the covert channel: servant courier / home-addressed post /
;     poste-restante, interception per the surface servant's dislike (the
;     Alice Yapp pattern), delivery into the recipient's hiding-spot cache
;     (the durable evidence trail). crime_of_passion / affair_fallout then
;     consume the knowledge through the evidence-mediated discover_affair.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think affair_correspondence
  (cooldown 1 m)
  (rng-stream incidents)

  (role @self (adult @self)
              {@self lover ?}
              ; @self signs the love letter - bind his OWN name for "Signed, ..".
              {@self name ?author_name})
  ; The paramour: a lover who is not also a spouse (the covert third party).
  (role ?paramour (any_human ?paramour)
    {@self lover ?paramour}
    (not {@self spouse ?paramour})
    (covert-affair-motive ?paramour)   ; belief-pure macro - cached
    ; @self names her in the letter body (a name value, not the live object).
    {?paramour name ?paramour_name}
    (select (policy first-match)))

  ; (when) is the monthly writer rate; the adult floor, live paramour and
  ; concealment motive (affair_macros.hs) are role filters above.
  (when (chance 0.5))

  (effects
    ; The love letter IS the affair fact, authored in natlang: her name in the
    ; body, "Signed, .." -> the (formulaic author ..) the reader resolves @i from.
    (send-covert-letter ?paramour
                         (nl_written_msg "I have taken ?paramour_name as a lover. Signed, ?author_name")
                         [k love_letter])))
