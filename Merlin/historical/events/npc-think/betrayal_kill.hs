; ----------------------------------------------------------------------------
; betrayal_kill.hs - instrumental homicide genesis: jealous betrayal.
;
; The MURDEROUS betrayal branch of the affair-homicide family (siblings:
; crime_of_passion.hs crave, clear_marriage.hs, rid_of_spouse.hs). A betrayed actor
; discovers a partner's affair from their OWN beliefs and kills the unfaithful
; partner, the interloper, or BOTH (the high-outrage + premeditation dual case).
; Distinct from generative-betrayal (the BROAD, non-lethal fallout - confront /
; expose / divorce); this is the lethal tail.
;
; PURE .hs. The discovery is cast as roles (the partner the actor believes has a
; third-party lover, and that interloper); appraise-betrayal mints the affair
; appraisal (anger at the partner, contempt at the interloper, a humiliation
; pressure); the blame decision is spelled out over composable reads:
;   spouse_blame = narcissism + (1 - compassion) + decorum + (warmth<0 ? 1 : 0)
;   lover_blame  = attach + compassion + (interloper-warmth<0 ? -warmth : 0)
;                  where attach = max(warmth,0) + 0.5*attraction toward the partner
;   dual_score   = anger-load + decorum + machiavellianism
; kill BOTH when dual_score >= 2.5 (rare); else the partner when spouse_blame >=
; lover_blame; else the interloper. /cause-pinned to the minted emotion ("kill
; <partner> <- {@self emotion anger}"). The rage pre-gate (volatility +
; psychopathy, scaled by disinhibition) keeps it the lethal tail.
; attempt_harm then consumes the goal(s) and executes a method as usual.
;
; Kept rare by design (rage gate + a known affair). To A/B, rename / remove this
; file (runtime-loaded; no rebuild).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event betrayal_kill
  (long-term-think)
  (rng-stream perpetration)

  (roles
    (role @self (template any_human))
    ; The unfaithful partner: a spouse or lover the actor believes keeps a
    ; third-party lover (the belief-query role filter). The interloper is resolved
    ; in (effects) via (interloper-of ?partner) - a cross-role read, not a role filter.
    (role ?partner (template any_human)
      (believes {@self spouse|lover ?partner}) (prefer 1)))

  ; Jealous-rage pre-gate. rage = mean(volatility, psychopathy); propensity =
  ; (1 - inhibition) * rage; fire at 0.02 * propensity.
  (when (chance (* 0.02
                   (* (- 1 (target {@self inhibition}))
                      (* 0.5 (+ (attr @self volatility)
                                (attr @self psychopathy)))))))

  (effects
    ; Resolve the interloper (the partner's third-party lover, in @self's own
    ; beliefs); @fail when no affair is known - then nothing fires.
    (bind (interloper-of ?partner) ?interloper)
    (if (alive ?interloper)
      (do
    ; Mint the affair appraisal (anger / contempt / humiliation) in @self's mind.
    (appraise-betrayal ?partner ?interloper)
    ; Dual when anger-load + decorum + machiavellianism >= 2.5 and both live.
    (if (and (>= (+ (emotion-load [k anger])
                    (+ (target {@self decorum}) (attr @self machiavellianism)))
                 2.5)
             (alive ?partner) (alive ?interloper))
        (do (begin-goal {@self kill ?partner}    /cause {@self emotion [k anger]})
            (begin-goal {@self kill ?interloper} /cause {@self emotion [k contempt]}))
        ; Else single-blame: partner when spouse_blame >= lover_blame, else interloper.
        (if (and (>= (+ (attr @self narcissism)
                        (+ (- 1 (target {@self compassion}))
                           (+ (target {@self decorum})
                              (if (< (stance-band ?partner warmth) 0) 1 0))))
                     (+ (+ (max 0 (stance-band ?partner warmth))
                           (* 0.5 (stance-band ?partner attraction)))
                        (+ (target {@self compassion})
                           (if (< (stance-band ?interloper warmth) 0)
                               (- 0 (stance-band ?interloper warmth)) 0))))
                 (alive ?partner))
            (begin-goal {@self kill ?partner} /cause {@self emotion [k anger]})
            (if (alive ?interloper)
                (begin-goal {@self kill ?interloper} /cause {@self emotion [k contempt]}))))))))
