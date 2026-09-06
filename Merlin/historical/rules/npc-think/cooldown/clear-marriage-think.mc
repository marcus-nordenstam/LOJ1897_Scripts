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
;   - (effects ...) forks on machiavellianism (P = 0.7 * mach): DIRECT MAINTAIN-proposes
;     {@self kill <spouse>} /caused_by the READ {@self lover <paramour>} attraction bond
;     (never re-minted, so the drive fades as the attraction does); INSTIGATED mints the
;     cheater's accomplice bond {@self accomplice <lover> /aux {<lover> kill <spouse>}}
;     and routes the murder proposal as a covert letter; the lover's side of the
;     conspiracy lives in conspiracy_adoption.hs, fired by READING that letter.
;     The (when) drops the drive when the spouse dies and latches the one-time impulse.
; attempt_harm then consumes the proposal and executes a method (poison's domestic
; deniability fits the co-resident victim). The murder proposal rides the covert
; letter channel ((route-covert-letter ... (written-msg {...} signed) ...)) - the conspiracy evidence trail implicating both.
;
; Kept rare by design (the dark floor + drive + base rate). To A/B, rename / remove
; this file (runtime-loaded; no rebuild).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think clear_marriage
  (cooldown 1 m)
  (rng-stream perpetration)

  ; @self signs the covert murder-proposal letter - bind his OWN name.
  (role @self {@self name ?author_name})
  (role ?spouse {?spouse isa [k human], condition [k alive]} {@self spouse ?spouse}
                ; @self names the spouse-victim in the plot (a name value).
                {?spouse name ?spouse_name}
                (select (policy first-match)))
  ; A covert lover (belief-query role filter: a lover who is not the spouse,
  ; and not KNOWN married - is-married is a pure belief macro, cached here).
  (role ?paramour {?paramour isa [k human], condition [k alive]}
    {@self lover ?paramour}:?lover_bond
    -{@self spouse ?paramour}
    -{?paramour spouse ?}   ; free to marry - cached
    (select (policy first-match)))

  ; Dark floor + the lover must be free to marry + drive + propensity
  ; (score_macros.hs: romantic-drive = attraction(lover) - warmth(spouse)).
  (when (and (>= (* (attr @self psychopathy) (attr @self machiavellianism)) 0.36)
             (>= (romantic-drive ?paramour ?spouse) 2)
             -{?spouse condition [k dead]}
             ; Latch BOTH committed paths so neither the chance nor the agency fork
             ; re-rolls: a running direct-kill proposal, OR an already-recruited
             ; accomplice bond, holds the drive; else the propensity roll tips it once.
             (or {@self kill ?spouse}
                 {@self accomplice ?paramour}
                 (chance
                   (* (crime-scale) 0.03
                      (* (attr @self psychopathy)
                         (* (attr @self machiavellianism)
                            (* (disinhibition)
                               (* (callousness @self)
                                  (romantic-drive ?paramour ?spouse))))))))))

  ; Agency fork (P(instigated) = 0.7 * machiavellianism, a schemer keeps clean hands).
  ; STAY on the committed path - only roll the fork when neither is committed yet, so
  ; the cheater never flips direct<->instigated or re-sends the letter.
  (utility want)
  (effects
    (if {@self kill ?spouse}
        ; Already committed DIRECT: maintain the kill /caused_by the READ lover bond.
        (then (maintain-proposal {@self kill ?spouse /caused_by ?lover_bond}))
        (else (if -{@self accomplice ?paramour}
            ; Not yet committed - fork ONCE.
            (then (if (chance (* 0.7 (attr @self machiavellianism)))
                ; INSTIGATED: recruit the lover. The accomplice bond carries the embedded
                ; plot as its AUX clause: {@self accomplice <lover> {<lover> kill <spouse>}}.
                ; The murder proposal rides the covert letter - urging is WANTING the
                ; target to act, so the CONTENT is a goal clause classified (msg-class urge);
                ; the lover learns it only by READING (no telepathy), and conspiracy_adoption
                ; decides whether they take up the deed.
                (then
                  (begin-belief {@self accomplice ?paramour {?paramour kill ?spouse}})
                  (send-covert-letter ?paramour (written-msg {@self goal {?paramour kill ?spouse}} (msg-class urge) signed) [k letter]))
                ; DIRECT: the cheater acts alone.
                (else (maintain-proposal {@self kill ?spouse /caused_by ?lover_bond}))))))))
    )
