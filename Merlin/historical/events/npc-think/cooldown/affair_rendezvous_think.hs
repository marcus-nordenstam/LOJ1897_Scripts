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
;   houseguest    (0.40) - silent hours at the actor's own home. Risk = a
;                  co-present onlooker (pry_think) noticing the private visit and
;                  warning the wronged spouse.
;   public crowd  (0.30) - co-presence at a public venue (theatre, else pub);
;                  an indiscretion plays out before whoever is ACTUALLY
;                  co-present this date (witness-copresence - the
;                  opportunity-set rule), and scandal whispers reach both
;                  spouses even unseen.
; Every tryst runs the shared (tryst-tail ...) (affair_macros.hs): mutual
; attraction nudge, the consummation roll's punctual HAVE_SEX_WITH records,
; the optional hand-delivered tryst_note, the paramour-spouse absence tick.
; Discovery is evidence-mediated: every leak is a witnessed EPISODE (witness-
; copresence act records); the witness's ongoing {cheater lover paramour} bonds are
; ABDUCED from the episode (Docs/hsim/hsim_abduction.md). A co-present onlooker who
; grows suspicious (pry_think) warns the wronged spouse - a told fact carried by
; gossip + discover_affair.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think affair_rendezvous
  (cooldown 1 m)
  (rng-stream incidents)

  (role @self (adult @self)
              (believes {@self lover ?}))
  ; The paramour: a lover who is not also a spouse (the covert third party).
  (role ?paramour (any_human ?paramour)
    (believes {@self lover ?paramour})
    (not (believes {@self spouse ?paramour}))
    (covert-affair-motive ?paramour)   ; belief-pure macro - cached
    (select (policy first-match)))

  ; (when) is the monthly rate (plus a trace); the adult floor, live paramour and
  ; concealment motive are role filters above.
  (when (and (chance 0.35) (debug-print "RENDEZ_FIRE @self para=?paramour")))

  (branches
    ; --- shared-hotel family excursion --------------------------------------
    (branch
      (weight (if (and (is-entity (find-building [k commercial_building hotel]))
                       (is-married @self)
                       (not (believes {@self class_situation [k class_situation lower]})))
                  (then 0.30) (else 0)))
      (effects
        (debug-print "RENDEZ_HOTEL @self para=?paramour")
        (bind (find-building [k commercial_building hotel]) ?hotel)
        (bind (spouse-of @self) ?spouse)
        ; The couple stays regardless; the register records them.
        (register-occupant ?hotel @self 0)
        (register-occupant ?hotel ?spouse 0)
        (record-hotel-guest ?hotel @self)
        (record-hotel-guest ?hotel ?spouse)
        ; lover_shadows: gated on @self's belief the paramour is drawn to @self + boldness.
        (if (and (or (believes {?paramour fancy @self})
                     (believes {?paramour desire @self})
                     (believes {?paramour crave @self}))
                 (chance (+ 0.40 (* 0.60 (attr ?paramour assertiveness)))))
            (then
              (register-occupant ?hotel ?paramour 0)
              (record-hotel-guest ?hotel ?paramour)
              ; The cover IS the threat: the spouse is in the next room, and a
              ; spouse already nursing a misgiving watches that much closer.
              ; Delivery is the EPISODE: everyone registered at the hotel this
              ; (Spouse-witnesses-indiscretion via the `lover` bond dropped with
              ; witness-copresence: `lover` is not an observable ACT, so the
              ; observability-gated auto-witness does not cover it. Suspicion +
              ; the gossip/told path remain the affair-discovery channels.)
              ; No actor-side absence tick: the spouse was co-present, the
              ; excursion explains him.
              (tryst-tail ?paramour ?hotel)))))

    ; --- houseguest silent hours --------------------------------------------
    (branch
      (weight (if (is-entity (home-of @self)) (then 0.40) (else 0)))
      (effects
        (debug-print "RENDEZ_HOUSE @self para=?paramour")
        (bind (home-of @self) ?home)
        ; The tryst puts @self and the paramour in the home; co-present onlookers
        ; (pry_think) may notice the private visit and warn the wronged spouse.
        (register-occupant ?home @self 0)
        (register-occupant ?home ?paramour 0)
        (tryst-tail ?paramour ?home)
        (bump-suspicion (spouse-of @self) @self 0.05)))

    ; --- public crowd ---------------------------------------------------------
    (branch
      (weight (if (or (is-entity (find-building [k commercial_building theatre]))
                      (is-entity (find-building [k commercial_building pub])))
                  (then 0.30) (else 0)))
      (effects
        (bind (if (is-entity (find-building [k commercial_building theatre]))
                  (then (find-building [k commercial_building theatre]))
                  (else (find-building [k commercial_building pub]))) ?venue)
        (debug-print "RENDEZ_PUBLIC @self para=?paramour")
        (register-occupant ?venue @self 1)
        (register-occupant ?venue ?paramour 1)
        ; An indiscretion plays out before whoever is ACTUALLY there this date
        ; (the opportunity-set rule); whispers reach the spouses regardless.
        (if (chance (* 0.10 (carelessness-of @self ?paramour)))
            (then
              ; (lover-bond witnessing dropped with witness-copresence: `lover`
              ; is not an observable ACT. Discovery keeps the suspicion path.)
              (bump-suspicion (spouse-of @self) @self 0.20)
              (bump-suspicion (spouse-of ?paramour) ?paramour 0.20)))
        (tryst-tail ?paramour ?venue)
        (bump-suspicion (spouse-of @self) @self 0.05)))))
