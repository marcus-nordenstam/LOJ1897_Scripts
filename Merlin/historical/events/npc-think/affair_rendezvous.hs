; ----------------------------------------------------------------------------
; affair_rendezvous.hs - the lovers MEET (see Docs/hsim/hsim_social.md
; "Conduct channel 2: rendezvous"). The npc-think sibling of
; affair_correspondence (the letter channel).
;
; PURE .hs (no C++ generator). Same covert-affair cast + concealment gate as
; the letter channel, at the 0.35 monthly rate; the MODE is a weighted
; (branches ...) pick over the substrate affordances, each branch its own risk
; surface + paper residue:
;   shared-hotel  (0.30) - family_excursion: the married couple stays at the
;                  hotel (cover = the co-present spouse; needs standing - not
;                  lower class) and the paramour shadows them, gated on their
;                  OWN attraction band + boldness. Risk = the spouse in the
;                  next room, watching closer the more she already suspects;
;                  residue = hotel_register entries for all three.
;   houseguest    (0.40) - silent hours at the actor's own home. Risk = the
;                  household staff at the keyhole (dislike-scaled, the same
;                  lever as letter interception; the Alice Yapp pattern) -
;                  a witness tells the wronged principal; even an unseen
;                  visitor is noticed.
;   public crowd  (0.30) - co-presence at a public venue (theatre, else pub);
;                  an indiscretion plays out before whoever is ACTUALLY
;                  co-present this date (witness-copresence - the
;                  opportunity-set rule), and scandal whispers reach both
;                  spouses even unseen.
; Every tryst runs the shared (tryst-tail ...) (affair_macros.hs): mutual
; attraction nudge, the consummation roll's punctual HAVE_SEX_WITH records,
; the optional hand-delivered tryst_note, the paramour-spouse absence tick.
; Discovery stays evidence-mediated: every leak plants {cheater lover
; paramour} in a WITNESS; gossip + discover_affair carry it to the betrayed
; spouse from there.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event affair_rendezvous
  (long-term-think)
  (rng-stream incidents)

  (roles
    (role @self (template any_human)
                (believes {@self lover ?}))
    ; The paramour: a lover who is not also a spouse (the covert third party).
    (role ?paramour (template any_human)
      (believes {@self lover ?paramour})
      (not (believes {@self spouse ?paramour}))
      (pick-first-matching-role)))

  ; Adult floor, live paramour, the concealment motive, the monthly rate.
  (when (and (>= (years-old @self) 18)
             (alive ?paramour)
             (covert-affair-motive ?paramour)
             (chance 0.35)))

  (branches
    ; --- shared-hotel family excursion --------------------------------------
    (branch
      (weight (if (and (is-entity (find-building [k commercial_building hotel]))
                       (is-married @self)
                       (not (believes {@self class_situation [k class_situation lower]})))
                  0.30 0))
      (effects
        (bind (find-building [k commercial_building hotel]) ?hotel)
        (bind (spouse-of @self) ?spouse)
        ; The couple stays regardless; the register records them.
        (register-occupant ?hotel @self 0)
        (register-occupant ?hotel ?spouse 0)
        (record-hotel-guest ?hotel @self)
        (record-hotel-guest ?hotel ?spouse)
        ; lover_shadows: gated on the paramour's OWN attraction + boldness.
        (if (and (>= (stance-band ?paramour @self attraction) 1)
                 (chance (+ 0.40 (* 0.60 (attr ?paramour assertiveness)))))
            (do
              (register-occupant ?hotel ?paramour 0)
              (record-hotel-guest ?hotel ?paramour)
              ; The cover IS the threat: the spouse is in the next room, and a
              ; spouse already nursing a misgiving watches that much closer.
              (if (chance (* 0.20 (carelessness-of @self ?paramour)
                             (+ 1 (suspicion-of ?spouse @self))))
                  (do (begin-belief ?spouse {@self lover ?paramour})
                      (begin-belief ?spouse {?paramour lover @self})))
              ; No actor-side absence tick: the spouse was co-present, the
              ; excursion explains him.
              (tryst-tail ?paramour ?hotel)))))

    ; --- houseguest silent hours --------------------------------------------
    (branch
      (weight (if (is-entity (home-of @self)) 0.40 0))
      (effects
        (bind (home-of @self) ?home)
        (register-occupant ?home @self 0)
        (register-occupant ?home ?paramour 0)
        ; The staff are the keyhole.
        (bind (prying-staff ?home) ?witness)
        (if (is-entity ?witness)
            (if (chance (min 0.5 (* 0.08
                                    (+ 1 (* 1.5 (hostility-of ?witness @self)))
                                    (+ 1 (suspicion-of ?witness @self)))))
                (do
                  (begin-belief ?witness {@self lover ?paramour})
                  (begin-belief ?witness {?paramour lover @self})
                  ; Word carried to the wronged principal: the actor's own
                  ; spouse first, else the paramour's.
                  (bind (if (is-entity (spouse-of @self))
                            (spouse-of @self) (spouse-of ?paramour)) ?ally)
                  (if (and (is-entity ?ally)
                           (not (= ?ally @self)) (not (= ?ally ?paramour)))
                      (do (begin-belief ?ally {@self lover ?paramour})
                          (begin-belief ?ally {?paramour lover @self}))))
                ; Even unseen at the door, the visitor was noticed.
                (bump-suspicion ?witness @self 0.08)))
        (tryst-tail ?paramour ?home)
        (bump-suspicion (spouse-of @self) @self 0.05)))

    ; --- public crowd ---------------------------------------------------------
    (branch
      (weight (if (or (is-entity (find-building [k commercial_building theatre]))
                      (is-entity (find-building [k commercial_building pub])))
                  0.30 0))
      (effects
        (bind (find-building [k commercial_building theatre]) ?theatre)
        (bind (if (is-entity ?theatre) ?theatre
                  (find-building [k commercial_building pub])) ?venue)
        (register-occupant ?venue @self 1)
        (register-occupant ?venue ?paramour 1)
        ; An indiscretion plays out before whoever is ACTUALLY there this date
        ; (the opportunity-set rule); whispers reach the spouses regardless.
        (if (chance (* 0.10 (carelessness-of @self ?paramour)))
            (do
              (witness-copresence @self lover ?paramour)
              (witness-copresence ?paramour lover @self)
              (bump-suspicion (spouse-of @self) @self 0.20)
              (bump-suspicion (spouse-of ?paramour) ?paramour 0.20)))
        (tryst-tail ?paramour ?venue)
        (bump-suspicion (spouse-of @self) @self 0.05)))))
