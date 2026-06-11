; ----------------------------------------------------------------------------
; affair - the betrayal-starvation lever.
;
; The piece the betrayal-homicide path was missing. run_generative_obsession
; (crime_of_passion.hs) detects a jealous spouse whose own spouse holds a
; THIRD-PARTY `lover`, and routes blame -> kill. But nothing in the substrate
; ever gave a MARRIED person a third-party lover:
;   - crush_forms gates OUT the already-attached (single people develop crushes);
;   - lovers pairs only the un-married / un-betrothed (the courting state);
;   - the seduce -> consummate rebound fires off `attachment_loss` (a LOST bond),
;     never a contented marriage straying.
; So betrayal fired ~1/run. This event supplies the missing genesis: a married
; NPC with an infidelity-prone disposition takes up with a known third party.
; The affair is the betrayal-detector's input - it is NOT itself a crime.
;
; The straying spouse (?actor) gates on a marriage AND a propensity product
; (openness x outgoingness x impropriety) - the modal faithful spouse never
; clears it; the bold, restless, low-decorum minority does. The paramour
; (?lover) is a known, age-appropriate, opposite-sex non-relative who is NOT
; the actor's own spouse. The bond is reciprocal (an affair is mutual), so if
; the paramour is themselves married their spouse can discover it too.
;
; `lover` is an inclusive_bond (Concepts.mon), so minting it on a person who
; already holds a {spouse} bond is well-formed - it does not collide with the
; spouse @excl placeholder and does not trip the exclusive-bond betray cascade.
;
; Schedule: (annually september) - one roll per married NPC per year, clear of
; the january betrothal / june wedding / july lovers ticks. A trickle is enough:
; crime_of_passion re-checks the standing affair MONTHLY, so a small stock of
; unfaithful spouses is read for years until a jealous partner finally snaps.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event affair
  (nl         "?actor strays into an affair with ?lover")
  (kind       _affair)
  (schedule   (annually september))
  (band      evening)
  (rng-stream incidents)

  (roles
    ; ?actor is the enumerated BELIEVER (role[0]) - it must be the outer role for
    ; the two-role spouse filter on ?lover to resolve. A married adult, not
    ; already carrying an affair, with the disposition to stray.
    (role ?actor (template any_human)
                 (>= (years-old ?actor) 18)
                 ; married ...
                 (believes ?actor {@self spouse ?})
                 ; ... and not already mid-affair (one paramour at a time; also
                 ; stops a contented re-mint every year on the same pair).
                 (not (believes ?actor {@self lover ?}))
                 ; infidelity propensity: open to novelty x outgoing x low
                 ; propriety. A product of three [0,1] traits - the modal
                 ; conscientious homebody never clears it; the restless,
                 ; sociable, low-decorum minority does (mirrors crush_forms'
                 ; openness x enthusiasm x compassion igniter, with decorum
                 ; INVERTED so impropriety, not warmth, is the driver).
                 ;; decorum is a DERIVED conduct dimension (belief), no longer
                 ;; an env attr (the reputation rework) - read it through the
                 ;; situation op. Un-derived reads contribute 0, making
                 ;; (- 1 ...) permissive - the not-yet-appraised stray freely.
                 (chance (* 0.5
                            (attr ?actor openness)
                            (attr ?actor enthusiasm)
                            (- 1 (situation ?actor decorum)))))
    (role ?lover (template any_human)
                 (not (= ?lover ?actor))
                 (>= (years-old ?lover) 18)
                 ; the paramour must NOT be the actor's own spouse (the affair is
                 ; by definition with a third party - same two-role believes shape
                 ; wedding.hs uses to recover the groom from the bride).
                 (not (believes ?actor {@self spouse ?lover}))
                 ; someone the actor actually knows (the acquaintance network the
                 ; activity-lanes co-presence sweep seeds), age-appropriate ...
                 (personally-knows ?actor ?lover)
                 (<= (- (years-old ?actor) (years-old ?lover))  15)
                 (>= (- (years-old ?actor) (years-old ?lover)) -15)
                 ; ... opposite-sex (period-default hetero majority; an attr read,
                 ; not a two-bound believes, so it gates reliably) and not kin.
                 (not (= (attr ?lover gender) (attr ?actor gender)))
                 (not (kin ?actor ?lover))
                 (chance 0.30)))

  ;; Live re-check: the un-attached actor filter is alpha-indexed and goes stale
  ;; within the september tick as earlier firings mint lover bonds; re-confirm
  ;; the actor is still affair-free so one straying spouse takes one paramour.
  (when (not (believes ?actor {@self lover ?})))

  (effects
    ; Reciprocal lover bond + mutual profile sync (mirrors lovers.hs's shape so
    ; downstream consumers - betrayal detection, the romantic-rival derive - see
    ; a fully-wired pair). The actor's spouse will read {?actor lover ?lover} in
    ; the obsession pass and route blame.
    (begin-belief ?actor lover ?lover)
    (begin-belief ?lover lover ?actor)
    ; Ground the pull in the stance substrate ON BOTH SIDES - a lover bond is
    ; constructed on physical attraction, so both parties hold at least the
    ; `fancy` band (0.4 clears the 0.24 band-entry threshold). Without the
    ; reciprocal nudge a paramour could "be a lover" while fancying nobody,
    ; which broke love_match's ability to marry the pair once both were free.
    (nudge-stance ?actor ?lover attraction 0.4)
    (nudge-stance ?lover ?actor attraction 0.4)
    (believe-about ?actor ?lover)
    (believe-about ?lover ?actor)
    (log _affair ?actor)))
