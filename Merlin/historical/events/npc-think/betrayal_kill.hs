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
; pressure); the blame decision reads over the layered score macros
; (score_macros.hs): kill BOTH when (dual-outrage-score) >= 2.5 (rare); else
; the partner when (blame-partner-score) >= (blame-interloper-score); else the
; interloper. /cause-pinned to the minted emotion ("kill <partner> <- {@self
; emotion anger}"). The rage pre-gate (dark-propensity over rage-disposition)
; keeps it the lethal tail.
; attempt_harm then consumes the goal(s) and executes a method as usual.
;
; Kept rare by design (rage gate + a known affair). To A/B, rename / remove this
; file (runtime-loaded; no rebuild).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-think betrayal_kill
  (long-term-think)
  (rng-stream perpetration)

  (role @self (any_human @self))
  ; The unfaithful partner: a spouse or lover the actor believes keeps a
  ; third-party lover (the belief-query role filter). The interloper is resolved
  ; in (effects) via (interloper-of ?partner) - a cross-role read, not a role filter.
  (role ?partner (any_human ?partner)
    (believes {@self spouse|lover ?partner}) (pick-first-matching-role))

  ; Jealous-rage pre-gate: the rage tail released by disinhibition, at the
  ; 0.02 base rate (score_macros.hs).
  (when (chance (* (crime-scale) 0.02
                   (dark-propensity @self (rage-disposition @self)))))

  (effects
    ; Resolve the interloper (the partner's third-party lover, in @self's own
    ; beliefs); @fail when no affair is known - then nothing fires.
    (bind (interloper-of ?partner) ?interloper)
    (if (alive ?interloper)
      (do
        ; Mint the affair appraisal (anger / contempt / humiliation) in @self's mind.
        (appraise-betrayal ?partner ?interloper)
        ; Dual (kill BOTH) when the outrage clears the bar and both live.
        (if (and (>= (dual-outrage-score) 2.5)
                (alive ?partner) (alive ?interloper))
            (do (begin-goal {@self kill ?partner}    /cause {@self emotion [k anger]})
                (begin-goal {@self kill ?interloper} /cause {@self emotion [k contempt]}))
            ; Else single-blame: the partner when blaming HER outweighs blaming the
            ; interloper (score_macros.hs spells out both scales), else the interloper.
            (if (and (>= (blame-partner-score ?partner)
                        (blame-interloper-score ?partner ?interloper))
                    (alive ?partner))
                (begin-goal {@self kill ?partner} /cause {@self emotion [k anger]})
                (if (alive ?interloper)
                    (begin-goal {@self kill ?interloper} /cause {@self emotion [k contempt]}))))))))
