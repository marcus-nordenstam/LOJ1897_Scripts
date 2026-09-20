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

(include "../../../definitions/roles.mc")

(npc-think affair_correspondence
  (cooldown 1 m)
  (rng-stream incidents)

  (match {@self age-band [k young-adult|middle-aged|mature|elderly]}
         {@self lover ?}
              ; @self signs the love letter - bind his OWN name for "Signed, ..".
         {@self name ?author_name})
  ; The paramour: a lover who is not also a spouse (the covert third party).
  (role ?paramour {?paramour isa [k human], condition [k alive]}
    {@self lover ?paramour}
    -{@self spouse ?paramour}
    (covert-affair-motive ?paramour)   ; belief-pure macro - cached
    ; @self names her in the letter body (a name value, not the live object).
    {?paramour name ?paramour_name}
    (select (policy first-match)))

  (role ?my-home {@self home ?my-home})

  ; Making the paper, penning it and posting it are THREE deeds, each its own act, and every
  ; rung reads the world for what is already done - an errand interrupted resumes where the
  ; paper actually lies. Ordered finish-before-start, so a letter in hand is dealt with
  ; before another is penned.
  (stable-or
    ; POST the finished letter. Getting to the pile is send-mail's own business.
    (try
      (role ?ltr [k love-letter] (spatial ?ltr co-located @self)
                                 {@self WRITE ?ltr ? /succ}
                                 -{@self send-mail ?ltr ? /succ})
      (role ?out [k outgoing-mail-stack] (spatial ?out building ?my-home))
      (effects
        ; A letter he has WRITTEN must carry what the mail service routes by; a filter here
        ; would leave an unstamped paper on the desk in silence.
        (check (substantial (attr ?ltr writing)))
        (check (substantial (attr ?ltr destination)))
        (maintain-proposal {@self send-mail ?ltr ?out})))


    ; PEN the blank one. write-doc walks him back to wherever the paper lies and proposes
    ; WRITE itself - a task that pens never proposes WRITE directly.
    ;
    ; The love letter IS the affair fact, and the ENVELOPE RIDES ON THE MESSAGE: WRITE stamps
    ; the addressee for the sorter at the door and the address for the mail service off the
    ; riders, so the letter needs no separate addressing deed. It is (written-msg ..) rather
    ; than the natlang twin because only this wrapper takes riders - nl-written-msg's one
    ; argument is the string itself.
    ;
    ; HER ADDRESS IS A GATE, not a check: a man who does not know where his lover lives
    ; genuinely cannot post to her, and waits until he does.
    (try
      (role ?ltr [k love-letter] (spatial ?ltr co-located @self)
                                 (unsubstantial (attr ?ltr writing)))
      (when {?paramour home ?her-home}
            {?her-home address ?her-address})
      (effects
        (maintain-proposal
          {@self write-doc ?ltr
                 (written-msg [/addressee ?paramour_name /address ?her-address /author ?author_name]
                              {@i lover ?paramour_name})})))

    ; MAKE one. The monthly writer rate gates THIS deed alone - once a letter exists it is
    ; finished off whatever the roll says, or a half-written affair sits on the desk for ever.
    (try
      (when (chance 0.5))
      (effects (maintain-proposal {@self CREATE-ENTITY [k love-letter]})))))
