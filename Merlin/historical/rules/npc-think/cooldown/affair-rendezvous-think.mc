; ----------------------------------------------------------------------------
; affair_rendezvous - the lovers MEET (see Docs/hsim/hsim_social.md "Conduct
; channel 2: rendezvous"). The npc-think sibling of affair_correspondence (the
; letter channel).
;
; PURE .hs (no C++ generator), no shared macro: ONE rule per rendezvous KIND,
; so the venue kind is IMPLICIT in each rule and its tryst note names the venue
; directly - an org premises (hotel / theatre / pub) by the org's name, a named
; residence by its name. Same covert-affair cast + concealment gate as the
; letter channel. Each rule's tail is the same shape: the mutual attraction
; nudge, the optional hand-delivered tryst-note, the paramour-spouse absence
; tick. Discovery stays evidence-mediated (witness-copresence + suspicion +
; gossip / discover_affair); `lover` is not an observable ACT, so no auto-witness.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

; --- shared-hotel family excursion ------------------------------------------
; The married couple stays at the hotel (cover = the co-present spouse; needs
; standing - not lower class) and the paramour shadows them, gated on their OWN
; attraction band + boldness. Residue = hotel-register entries for all three;
; risk = the spouse in the next room.
(npc-think affair_rendezvous_hotel
  (cooldown 1 m)
  (rng-stream incidents)

  (role @self (adult @self)
              {@self lover ?}
              (is-married @self)
              -{@self class-situation [k class-situation lower]}
              {@self name ?author_name})
  (role ?paramour (any_human ?paramour)
    {@self lover ?paramour}
    -{@self spouse ?paramour}
    (covert-affair-motive ?paramour)
    (select (policy first-match)))
  ; The venue is a hotel @self KNOWS - knowing none, there is no assignation to plan.
  (role ?venue [k commercial-building hotel]
    (select (score (near @self ?venue)) (policy roulette)))

  (when (and (chance 0.10)
             (or {?paramour fancy @self}
                 {?paramour desire @self}
                 {?paramour crave @self})
             (chance (+ 0.40 (* 0.60 (attr ?paramour assertiveness))))))

  (utility want)

  (effects
    (spouse-of @self): ?spouse
    (register-occupant ?venue @self 0)
    (register-occupant ?venue ?spouse 0)
    (register-occupant ?venue ?paramour 0)
    (record-hotel-guest ?venue @self)
    (record-hotel-guest ?venue ?spouse)
    (record-hotel-guest ?venue ?paramour)
    (nudge-stance @self ?paramour attraction 0.10)
    (nudge-stance ?paramour @self attraction 0.10)
    ; the hotel is an org premises - the note names it by the org's name.
    (if (and (chance 0.30) {?paramour home ?paramour_home}
             {? workplace ?venue}: ?wob
             (bind ?wob.subject ?org)
             {?org name ?venue_name})
        (then
          (post-letter [k tryst-note]
                (nl-written-msg "I met you at ?venue_name. Signed, ?author_name")
                ?paramour_home ?paramour)))
    (bump-suspicion (spouse-of ?paramour) ?paramour 0.05)))

; --- houseguest silent hours ------------------------------------------------
; Silent hours at the actor's own home. Risk = a co-present onlooker (pry_think)
; noticing the private visit and warning the wronged spouse.
(npc-think affair_rendezvous_home
  (cooldown 1 m)
  (rng-stream incidents)

  (role @self (adult @self)
              {@self lover ?}
              {@self name ?author_name})
  (role ?paramour (any_human ?paramour)
    {@self lover ?paramour}
    -{@self spouse ?paramour}
    (covert-affair-motive ?paramour)
    (select (policy first-match)))

  (when (and (chance 0.14) {@self home ?venue}))

  (utility want)

  (effects
    (register-occupant ?venue @self 0)
    (register-occupant ?venue ?paramour 0)
    (nudge-stance @self ?paramour attraction 0.10)
    (nudge-stance ?paramour @self attraction 0.10)
    ; @self's own home: a named residence carries a name; a plain house has only
    ; an address (not expressible in a note yet), so unnamed homes write no note.
    (if (and (chance 0.30) {?paramour home ?paramour_home} {?venue name ?})
        (then
          (any {?venue name ?venue_name})
          (post-letter [k tryst-note]
                (nl-written-msg "I met you at ?venue_name. Signed, ?author_name")
                ?paramour_home ?paramour)))
    (bump-suspicion (spouse-of @self) @self 0.05)
    (bump-suspicion (spouse-of ?paramour) ?paramour 0.05)))

; --- public crowd -----------------------------------------------------------
; Co-presence at a public venue (theatre, else pub); an indiscretion plays out
; before whoever is ACTUALLY co-present, and scandal whispers reach both spouses
; even unseen.
(npc-think affair_rendezvous_public
  (cooldown 1 m)
  (rng-stream incidents)

  (role @self (adult @self)
              {@self lover ?}
              {@self name ?author_name})
  (role ?paramour (any_human ?paramour)
    {@self lover ?paramour}
    -{@self spouse ?paramour}
    (covert-affair-motive ?paramour)
    (select (policy first-match)))
  ; The outing venue is a commercial building @self KNOWS; the score keeps the old
  ; theatre-before-pub preference (either outranks any other known premises), and the
  ; (when) below bars the rest.
  (role ?venue [k commercial-building]
    (select (score (+ (near @self ?venue)
                      (* 10 (is-a ?venue [k commercial-building theatre]))
                      (* 5  (is-a ?venue [k commercial-building pub]))))
            (policy argmax)))

  (when (and (chance 0.11)
             (or (is-a ?venue [k commercial-building theatre])
                 (is-a ?venue [k commercial-building pub]))))

  (utility want)

  (effects
    (register-occupant ?venue @self 1)
    (register-occupant ?venue ?paramour 1)
    ; an indiscretion before whoever is there this date; whispers reach the spouses.
    (if (chance (* 0.10 (carelessness-of @self ?paramour)))
        (then
          (bump-suspicion (spouse-of @self) @self 0.20)
          (bump-suspicion (spouse-of ?paramour) ?paramour 0.20)))
    (nudge-stance @self ?paramour attraction 0.10)
    (nudge-stance ?paramour @self attraction 0.10)
    ; the theatre / pub is an org premises - the note names it by the org's name.
    (if (and (chance 0.30) {?paramour home ?paramour_home}
             {? workplace ?venue}: ?wob
             (bind ?wob.subject ?org)
             {?org name ?venue_name})
        (then
          (post-letter [k tryst-note]
                (nl-written-msg "I met you at ?venue_name. Signed, ?author_name")
                ?paramour_home ?paramour)))
    (bump-suspicion (spouse-of @self) @self 0.05)
    (bump-suspicion (spouse-of ?paramour) ?paramour 0.05)))
