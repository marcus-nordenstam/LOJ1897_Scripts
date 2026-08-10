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
;     {@self kill <spouse>} /caused_by {@self lover <paramour>}; INSTIGATED mints the
;     cheater's accomplice bond {@self accomplice <lover> /aux {<lover> kill <spouse>}}
;     and routes the murder proposal as a covert letter; the lover's side of the
;     conspiracy lives in conspiracy_adoption.hs, fired by READING that letter.
; attempt_harm then consumes the goal and executes a method (poison's domestic
; deniability fits the co-resident victim). The murder proposal rides the covert
; letter channel ((route-covert-letter ... (written-msg {...} signed) ...)) - the conspiracy evidence trail implicating both.
;
; Kept rare by design (the dark floor + drive + base rate). To A/B, rename / remove
; this file (runtime-loaded; no rebuild).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think clear_marriage
  (cooldown 1 m)
  (rng-stream perpetration)

  ; @self signs the covert murder-proposal letter - bind his OWN name.
  (role @self (believes {@self name ?author_name}))
  (role ?spouse (any_human ?spouse) {@self spouse ?spouse}
                ; @self names the spouse-victim in the plot (a name value).
                (believes {?spouse name ?spouse_name})
                (select (policy first-match)))
  ; A covert lover (belief-query role filter: a lover who is not the spouse,
  ; and not KNOWN married - is-married is a pure belief macro, cached here).
  (role ?paramour (any_human ?paramour)
    {@self lover ?paramour}
    (not {@self spouse ?paramour})
    (not {?paramour spouse ?})   ; free to marry - cached
    (select (policy first-match)))

  ; Dark floor + the lover must be free to marry + drive + propensity
  ; (score_macros.hs: romantic-drive = attraction(lover) - warmth(spouse)).
  (when (and (>= (* (attr @self psychopathy) (attr @self machiavellianism)) 0.36)
             (>= (romantic-drive ?paramour ?spouse) 2)
             (chance
               (* (crime-scale) 0.03
                  (* (attr @self psychopathy)
                     (* (attr @self machiavellianism)
                        (* (disinhibition)
                           (* (callousness @self)
                              (romantic-drive ?paramour ?spouse)))))))))

  ; Agency fork (P(instigated) = 0.7 * machiavellianism, a schemer keeps clean hands).
  (effects
    (if (chance (* 0.7 (attr @self machiavellianism)))
        ; INSTIGATED: the cheater recruits the lover. The accomplice bond carries the
        ; embedded plot as its AUX clause (4th positional field): {@self accomplice
        ; <lover> {<lover> kill <spouse>}} - target = the lover, aux = the kill plot.
        (then
          (begin-belief {@self accomplice ?paramour {?paramour kill ?spouse}})
          ; The murder proposal rides the covert letter channel - the cheater urges
          ; the lover to kill the spouse. Composed here (.hs content); an intercepted
          ; or cached letter is the conspiracy evidence trail implicating both.
          ; The lover's side of the conspiracy is NOT minted here: they learn the
          ; plot by READING the letter (read_secret_letters adopts the urge belief
          ; into their mind), and conspiracy_adoption.hs decides whether they take
          ; up the deed - no telepathy, and an intercepted letter means the lover
          ; never learns of the plot at all.
          ; @you = ?paramour (the covert letter's recipient); the plot's doer
          ; resolves to the reader, so conspiracy_adoption sees {@self kill <spouse>}.
          (send-covert-letter ?paramour (nl_written_msg "I urge you to kill ?spouse_name. Signed, ?author_name") [k letter]))
        ; DIRECT: the cheater acts alone. The lover bond (find-or-create reuses the
        ; gating belief) is the motive pin.
        (else (begin-belief {@self lover ?paramour}): ?lover_bond
              (begin-goal {@self kill ?spouse} /caused_by ?lover_bond)))))
