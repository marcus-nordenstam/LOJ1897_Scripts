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
; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
; (relational: gated on marriage + personally-knows, no physical co-presence).
; It now fires MONTHLY instead of annually, so the actor (chance) is /12 (0.5 ->
; 0.04) to hold the annual trickle. A trickle is enough: crime_of_passion
; re-checks the standing affair MONTHLY, so a small stock of unfaithful spouses
; is read for years until a jealous partner finally snaps.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event affair
  (nl         "?actor strays into an affair with ?lover")
  (kind       _affair)
  (band      evening)
  (rng-stream incidents)

  ; PLACE-EMERGENT (Section 4.11): the affair sparks with a CO-PRESENT third party
  ; (a colleague at the workplace, the boss, a fellow club-goer), via the `affair`
  ; affordance. ?actor is PRESET from the venue's occupants, so its eligibility
  ; (married, not-already-straying, the propensity to stray) moves to (when).
  (roles
    (role ?actor (template any_human))
    (role ?lover (template any_human)
                 (not (= ?lover ?actor))
                 (>= (years-old ?lover) 18)
                 ; the paramour must NOT be the actor's own spouse (a third party).
                 (not (believes ?actor {@self spouse ?lover}))
                 ; the affair ignites with whoever shares the venue this band.
                 (co-present ?actor ?lover)
                 (<= (- (years-old ?actor) (years-old ?lover))  15)
                 (>= (- (years-old ?actor) (years-old ?lover)) -15)
                 ; opposite-sex (period-default hetero majority; attr read), non-kin.
                 (not (= (attr ?lover gender) (attr ?actor gender)))
                 (not (kin ?actor ?lover))))

  ;; Actor eligibility (preset role-0 skips role filters): a married adult, not
  ;; already mid-affair, with the disposition to stray - openness x enthusiasm x
  ;; impropriety (decorum INVERTED; an un-derived decorum reads 0, so the
  ;; not-yet-appraised stray freely). Per-OCCASION now (the afford rate sets the
  ;; opportunity frequency), so the chance is the full propensity, not the /12.
  (when (and (>= (years-old ?actor) 18)
             (believes ?actor {@self spouse ?})
             (not (believes ?actor {@self lover ?}))
             (chance (* 0.4
                        (attr ?actor openness)
                        (attr ?actor enthusiasm)
                        (- 1 (situation ?actor decorum))))))

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
