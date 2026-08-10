; ----------------------------------------------------------------------------
; affair_rendezvous - the lovers MEET (see Docs/hsim/hsim_social.md "Conduct
; channel 2: rendezvous"). The npc-think sibling of affair_correspondence (the
; letter channel).
;
; PURE .hs (no C++ generator), no shared macro: ONE event per rendezvous KIND,
; so the venue kind is IMPLICIT in each event and its tryst note names the venue
; directly - an org premises (hotel / theatre / pub) by the org's name, a named
; residence by its name. Same covert-affair cast + concealment gate as the
; letter channel. Each event's tail is the same shape: the mutual attraction
; nudge, the optional hand-delivered tryst_note, the paramour-spouse absence
; tick. Discovery stays evidence-mediated (witness-copresence + suspicion +
; gossip / discover_affair); `lover` is not an observable ACT, so no auto-witness.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; --- shared-hotel family excursion ------------------------------------------
; The married couple stays at the hotel (cover = the co-present spouse; needs
; standing - not lower class) and the paramour shadows them, gated on their OWN
; attraction band + boldness. Residue = hotel_register entries for all three;
; risk = the spouse in the next room.
(npc-think affair_rendezvous_hotel
  (cooldown 1 m)
  (rng-stream incidents)

  (role @self (adult @self)
              {@self lover ?}
              (is-married @self)
              (not {@self class_situation [k class_situation lower]})
              (believes {@self name ?author_name}))
  (role ?paramour (any_human ?paramour)
    {@self lover ?paramour}
    (not {@self spouse ?paramour})
    (covert-affair-motive ?paramour)
    (select (policy first-match)))

  (when (and (chance 0.10)
             (is-entity (find-building [k commercial_building hotel]))
             (or (any {?paramour fancy @self} (out int))
                 (any {?paramour desire @self} (out int))
                 (any {?paramour crave @self} (out int)))
             (chance (+ 0.40 (* 0.60 (attr ?paramour assertiveness))))))

  (effects
    (find-building [k commercial_building hotel]): ?venue
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
    (if (and (chance 0.30) (is-entity (home-of ?paramour))
             (any {? workplace ?venue}): ?wob
             ?wob.subject: ?org
             (any {?org name ?}).target: ?venue_name)
        (then
          (spawn-letter [k tryst_note]
                (nl_written_msg "I met you at ?venue_name. Signed, ?author_name")
                (home-of ?paramour))))
    (bump-suspicion (spouse-of ?paramour) ?paramour 0.05)))

; --- houseguest silent hours ------------------------------------------------
; Silent hours at the actor's own home. Risk = a co-present onlooker (pry_think)
; noticing the private visit and warning the wronged spouse.
(npc-think affair_rendezvous_home
  (cooldown 1 m)
  (rng-stream incidents)

  (role @self (adult @self)
              {@self lover ?}
              (believes {@self name ?author_name}))
  (role ?paramour (any_human ?paramour)
    {@self lover ?paramour}
    (not {@self spouse ?paramour})
    (covert-affair-motive ?paramour)
    (select (policy first-match)))

  (when (and (chance 0.14) (is-entity (home-of @self))))

  (effects
    (home-of @self): ?venue
    (register-occupant ?venue @self 0)
    (register-occupant ?venue ?paramour 0)
    (nudge-stance @self ?paramour attraction 0.10)
    (nudge-stance ?paramour @self attraction 0.10)
    ; @self's own home: a named residence carries a name; a plain house has only
    ; an address (not expressible in a note yet), so unnamed homes write no note.
    (if (and (chance 0.30) (is-entity (home-of ?paramour)) (any {?venue name ?} (out int)))
        (then
          (any {?venue name ?}).target: ?venue_name
          (spawn-letter [k tryst_note]
                (nl_written_msg "I met you at ?venue_name. Signed, ?author_name")
                (home-of ?paramour))))
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
              (believes {@self name ?author_name}))
  (role ?paramour (any_human ?paramour)
    {@self lover ?paramour}
    (not {@self spouse ?paramour})
    (covert-affair-motive ?paramour)
    (select (policy first-match)))

  (when (and (chance 0.11)
             (or (is-entity (find-building [k commercial_building theatre]))
                 (is-entity (find-building [k commercial_building pub])))))

  (effects
    (if (is-entity (find-building [k commercial_building theatre]))
              (then (find-building [k commercial_building theatre]))
              (else (find-building [k commercial_building pub]))): ?venue
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
    (if (and (chance 0.30) (is-entity (home-of ?paramour))
             (any {? workplace ?venue}): ?wob
             ?wob.subject: ?org
             (any {?org name ?}).target: ?venue_name)
        (then
          (spawn-letter [k tryst_note]
                (nl_written_msg "I met you at ?venue_name. Signed, ?author_name")
                (home-of ?paramour))))
    (bump-suspicion (spouse-of @self) @self 0.05)
    (bump-suspicion (spouse-of ?paramour) ?paramour 0.05)))
