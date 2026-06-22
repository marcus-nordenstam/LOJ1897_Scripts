; ----------------------------------------------------------------------------
; affair (npc-think) - the betrayal-starvation lever.
;
; The piece the betrayal-homicide path was missing. run_generative_obsession
; (crime_of_passion.hs) detects a jealous spouse whose own spouse holds a
; THIRD-PARTY `lover`, and routes blame -> kill. But nothing else gives a MARRIED
; person a third-party lover (crush_forms gates out the attached; lovers pairs
; only the unmarried; the seduce rebound fires off a LOST bond). So this event
; supplies the missing genesis: a married NPC with an infidelity-prone
; disposition takes up with a known third party. The affair is the
; betrayal-detector's input - it is NOT itself a crime.
;
; A mental change (a reciprocal lover bond), so npc-think. RELATIONAL: gated on
; marriage + personally-knows, no physical co-presence - the paramour is a known
; third party (a colleague, the boss, a fellow club-goer), bound by the social
; tie, not whoever shares a room. Fired by the per-NPC emergent pass MONTHLY, so
; the actor (chance) is /12 (0.5 -> 0.04) to hold the annual trickle. A trickle
; is enough: crime_of_passion re-checks the standing affair MONTHLY, so a small
; stock of unfaithful spouses is read for years until a jealous partner snaps.
;
; The straying spouse (?actor) gates on a marriage AND a propensity product
; (openness x enthusiasm x impropriety = decorum inverted). The paramour (?lover)
; is a known, age-appropriate, opposite-sex non-relative who is NOT the actor's
; own spouse. `lover` is an inclusive_bond, so minting it on a married person is
; well-formed (no @excl collision, no exclusive-bond betray cascade).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event affair
  (sim-window-start)
  (nl         "@self strays into an affair with ?lover")
  (rng-stream incidents)

  (roles
    ;; @self - a married adult, not already mid-affair, with the disposition to
    ;; stray - openness x enthusiasm x impropriety (decorum INVERTED; an un-derived
    ;; decorum reads 0, so the not-yet-appraised stray freely). The chance is /12 of
    ;; the annual 0.5, rolled once per NPC per window.
    (role @self (template any_human)
                (>= (years-old @self) 18)
                (believes {@self spouse ?})
                (not (believes {@self lover ?}))
                (chance (* 0.04
                           (attr @self openness)
                           (attr @self enthusiasm)
                           (- 1 (situation @self decorum)))))
    (role ?lover (template any_human)
                 (not (= ?lover @self))
                 (>= (years-old ?lover) 18)
                 ; the paramour must NOT be @self's own spouse (a third party).
                 (not (believes {@self spouse ?lover}))
                 ; the affair ignites with a known third party (social tie).
                 (personally-knows @self ?lover)
                 (<= (- (years-old @self) (years-old ?lover))  15)
                 (>= (- (years-old @self) (years-old ?lover)) -15)
                 ; opposite-sex (period-default hetero majority; attr read), non-kin.
                 (not (= (attr ?lover gender) (attr @self gender)))
                 (not (kin @self ?lover))))

  (effects
    ; Reciprocal lover bond + mutual profile sync (mirrors lovers.hs's shape so
    ; downstream consumers - betrayal detection, the romantic-rival derive - see a
    ; fully-wired pair). @self's spouse will read {@self lover ?lover} in the
    ; obsession pass and route blame.
    (begin-belief @self lover ?lover)
    (begin-belief ?lover lover @self)
    ; Ground the pull in the stance substrate ON BOTH SIDES - a lover bond is
    ; constructed on physical attraction, so both hold at least the `fancy` band
    ; (0.4 clears the 0.24 band-entry threshold). Without the reciprocal nudge a
    ; paramour could "be a lover" while fancying nobody, which broke love_match's
    ; ability to marry the pair once both were free.
    (nudge-stance @self ?lover attraction 0.4)
    (nudge-stance ?lover @self attraction 0.4)
    (believe-about @self ?lover)
    (believe-about ?lover @self)
    (log _affair @self)))
