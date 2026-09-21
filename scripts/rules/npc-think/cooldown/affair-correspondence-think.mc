; ----------------------------------------------------------------------------
; affair_correspondence.mc - the letter channel of a covert affair
; (see Docs/hsim/hsim_social.md "Conduct channel 1: correspondence").
;
; PURE .mc (no C++ generator) - sibling of the other affair/motive rules:
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

(include "../../../definitions/roles.mc")

(npc-think affair_correspondence
  (cooldown 1 m)
  (rng-stream incidents)

  (role @self {@self age-band [k young-adult|middle-aged|mature|elderly]}
              {@self lover ?}
                   ; @self signs the love letter - bind his OWN name for "Signed, ..".
              {@self name ?author_name}
    ; The paramour: a lover who is not also a spouse (the covert third party).
    (role ?paramour {?paramour isa [k human], condition [k alive]}
      {@self lover ?paramour}
      -{@self spouse ?paramour}
      (covert-affair-motive ?paramour)   ; belief-pure macro - cached
      ; @self names her in the letter body (a name value, not the live object).
      {?paramour name ?paramour_name}
      (select (policy first-match))

      (role ?my-home {@self home ?my-home}

        ; Make the paper, pen it, post it - three deeds, each reading the world for what is done.
        ; Ordered finish-before-start, so a letter in hand is dealt with before another is penned.
        (stable-or
          ; Getting to the pile is send-mail's own business.
          (try
            (role ?ltr [k love-letter] (spatial ?ltr co-located @self)
                                       {@self WRITE ?ltr ? /succ}
                                       -{@self send-mail ?ltr ? /succ}
              (role ?out [k outgoing-mail-stack] (spatial ?out building ?my-home)
                (effects
                  ; A written letter must carry what the mail service routes by; a filter would leave an
                  ; unstamped paper on the desk in silence.
                  (check (substantial (attr ?ltr writing)))
                  (check (substantial (attr ?ltr destination)))
                  (maintain-proposal {@self send-mail ?ltr ?out})))))


          ; The love letter IS the affair fact, and its envelope rides on the message - WRITE stamps
          ; addressee and address off the riders, so there is no addressing deed. Not knowing where
          ; she lives is a gate, not a check: he simply cannot post to her yet.
          (try
            (role ?ltr [k love-letter] (spatial ?ltr co-located @self)
                                       (unsubstantial (attr ?ltr writing))
              (when {?paramour home ?her-home}
                    {?her-home address ?her-address})
              (effects
                (maintain-proposal
                  {@self write-doc ?ltr
                         (written-msg [/addressee ?paramour_name /address ?her-address /author ?author_name]
                                      {@i lover ?paramour_name})}))))

          ; The monthly writer rate gates the MAKING alone - once a letter exists it is finished off
          ; whatever the roll says, or a half-written affair sits on the desk for ever.
          (try
            (when (chance 0.5))
            (effects (maintain-proposal {@self CREATE-ENTITY [k love-letter]}))))))))
