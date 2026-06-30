; ----------------------------------------------------------------------------
; clear_marriage.hs - instrumental homicide genesis: clear the marriage.
;
; A cold instrumental branch of the affair-homicide family (siblings:
; crime_of_passion.hs, betrayal_kill.hs, rid_of_spouse.hs). A married actor with a
; covert third-party lover (themselves free to marry) WANTS the lover; the OBSTACLE
; is their own innocent spouse. They either kill the spouse DIRECTLY (the Florence
; Maybrick shape) or INSTIGATE the lover to do it - a conspiracy, the cheater
; staying physically clean. Calculating, not enraged, so it carries its OWN
; dark-tail gate (no rage gate).
;
; PURE .hs over composable ops:
;   - (role ?paramour ...) binds an UNMARRIED lover who is not the spouse;
;     (role ?spouse ...) binds the spouse (so the actor is married by construction);
;   - (when ...) is the dark floor (psychopathy * machiavellianism >= 0.36), the
;     drive (attraction band to the lover minus warmth band to the spouse >= 2), and
;     the propensity roll (psycho * mach * disinhibition * (1-compassion) * drive at
;     the 0.03 base rate);
;   - (effects ...) forks on machiavellianism (P = 0.7 * mach): DIRECT mints
;     {@self kill <spouse>} /cause {@self lover <paramour>}; INSTIGATED mints the
;     cheater's accomplice bond {@self accomplice <lover> /aux {<lover> kill <spouse>}}
;     and, if the lover DESIRES the cheater (their attraction band >= 2) and is dark
;     enough, the lover takes up the deed - their own accomplice bond + kill goal
;     (a cross-mind mint into the lover's mind).
; attempt_harm then consumes the goal and executes a method (poison's domestic
; deniability fits the co-resident victim). The murder proposal rides the covert
; letter channel ((route-covert-letter ... (msg {@self urge {?paramour kill
; ?spouse}}) ...)) - the conspiracy evidence trail implicating both.
;
; Kept rare by design (the dark floor + drive + base rate). To A/B, rename / remove
; this file (runtime-loaded; no rebuild).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event clear_marriage
  (long-term-think)
  (rng-stream perpetration)

  (roles
    (role @self (template any_human))
    (role ?spouse (template any_human) (believes {@self spouse ?spouse}) (prefer 1))
    ; A covert lover (belief-query role filter: a lover who is not the spouse). The
    ; unmarried check is an opaque verb gate, so it lives in (when), not the filter.
    (role ?paramour (template any_human)
      (believes {@self lover ?paramour})
      (not (believes {@self spouse ?paramour}))
      (prefer 1)))

  ; Dark floor + the lover must be free to marry + drive + propensity.
  ; drive = attraction(lover) - warmth(spouse).
  (when (and (>= (* (attr @self psychopathy) (attr @self machiavellianism)) 0.36)
             (not (is-married ?paramour))
             (>= (- (stance-band ?paramour attraction) (stance-band ?spouse warmth)) 2)
             (chance
               (* 0.03
                  (* (attr @self psychopathy)
                     (* (attr @self machiavellianism)
                        (* (- 1 (target {@self inhibition}))
                           (* (- 1 (target {@self compassion}))
                              (- (stance-band ?paramour attraction)
                                 (stance-band ?spouse warmth))))))))))

  ; Agency fork (P(instigated) = 0.7 * machiavellianism, a schemer keeps clean hands).
  (effects
    (if (chance (* 0.7 (attr @self machiavellianism)))
        ; INSTIGATED: the cheater recruits the lover. The accomplice bond carries the
        ; embedded plot as its AUX clause (4th positional field): {@self accomplice
        ; <lover> {<lover> kill <spouse>}} - target = the lover, aux = the kill plot.
        (do
          (begin-belief {@self accomplice ?paramour {?paramour kill ?spouse}})
          ; The murder proposal rides the covert letter channel - the cheater urges
          ; the lover to kill the spouse. Composed here (.hs content); an intercepted
          ; or cached letter is the conspiracy evidence trail implicating both.
          (route-covert-letter ?paramour (msg {@self urge {?paramour kill ?spouse}}) [k letter])
          ; The lover adopts if they DESIRE the cheater (attraction band >= 2) and
          ; are dark enough - their own bond + kill goal, minted in THEIR mind.
          (if (and (>= (stance-band ?paramour @self attraction) 2)
                   (chance (attr ?paramour psychopathy)))
              (do
                (begin-belief ?paramour {?paramour accomplice @self {?paramour kill ?spouse}})
                (begin-goal {?paramour kill ?spouse} /cause {?paramour accomplice @self}))))
        ; DIRECT: the cheater acts alone.
        (begin-goal {@self kill ?spouse} /cause {@self lover ?paramour}))))
