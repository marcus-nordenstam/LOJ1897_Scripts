; ----------------------------------------------------------------------------
; jilt - the Smith genesis (see Docs/hsim/hsim_social.md "Ending an affair by
; choice: jilt").
;
; A lover bond endable by CHOICE - before this event, lover bonds ended only
; by death, marriage or divorce. The lead form is betrothal-triggered: an NPC
; holding a `lover` bond acquires a `fiancee` bond with a THIRD party (the
; betrothal / advantageous_match output) and breaks with the lover. love_match
; converts a lover pair INTO its own betrothal, so the ?jilted filters exclude
; the case where the fiancee IS the lover.
;
; One-sided ending is the load-bearing design point: ONLY the jilter's
; {@self lover ?jilted} ends. The jilted party's {@self lover <jilter>}
; survives ongoing while hers is interval-ended - that subjective divergence
; IS the obsessive-ex representation, free from the substrate (covert plan
; axiom 0). No new "obsession" state.
;
; The incident-anchor mints {@self jilt ?jilted} in BOTH minds; the patient
; cascade (Tasks.mon: abandonment_act + wrong_act) mints grief +
; attachment_loss + status_loss + anger + humiliation + injustice in the
; jilted - the exact pressure stack the new (affinity attachment_loss coerce)
; deliberation row reads on later ticks. Warmth curdles via nudge-stance;
; attraction is deliberately NOT nudged down - longing persists.
;
; Tuning knobs: the (chance 0.6) jilt-on-betrothal probability. A stance-decay
; jilt form (the bond simply cools, no betrothal) is a deferred knob - add a
; sibling event gated on (not (is-attracted-to @self ?jilted)) when
; the distribution wants it.
;
; EMERGENT (Section 4.11): no (schedule) - both jilt forms fire via the per-NPC
; emergent pass (relational, bond-gated, no physical co-presence), monthly as
; before, so a betrothed affair-holder breaks with the lover within a couple of
; months of betrothal. (chance unchanged - they were already monthly.)
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think jilt
  (sim-window-think)
  (rng-stream marriages)

  ; The jilter: holds BOTH a lover bond and a betrothal (to someone else -
  ; the ?jilted filters enforce the third party).
  (role @self 
                (believes {@self lover ?})
                (believes {@self fiancee ?}))
  ; The jilted: the jilter's lover who is NOT the jilter's fiancee (the
  ; two-bound believes shape wedding.hs uses to recover the groom).
  (role ?jilted (any_human ?jilted)
                (believes {@self lover ?jilted})
                (not (believes {@self fiancee ?jilted}))
                (select (policy first-match)))

  ;; (chance 0.6) moved here from the @self role (non-belief gate).
  ;; Live re-check: an earlier firing this tick may already have ended the
  ;; jilter's lover bond (one jilt per jilter per tick).
  (when (chance (* (crime-scale) 0.6)))

  (cont-fire-effects
    ; One-sided ending - ONLY the jilter's belief (see header).
    (end-belief @self lover ?jilted)
    ; The act-record in both minds + the appraisal cascade in each.
    (incident-anchor @self jilt ?jilted)
    ; Warmth curdles; attraction is NOT touched (longing persists).
    (nudge-stance ?jilted @self warmth -0.4)
    ))

; ----------------------------------------------------------------------------
; jilt_for_station - the class-ambition jilt (the literal Smith opening).
;
; betrothal and love_match gate lover-holders by VIABILITY: a same-station
; lover keeps one out of the arranged market (those pairs wed via
; love_match), but a lover beneath one's station is no impediment in the
; family's eyes - the arranged match proceeds OVER the secret affair, landing
; the jilter in the lover+fiancee state the betrothal-triggered `jilt` above
; consumes (the engagement-first Smith ordering). This sibling form supplies
; the anticipatory half: a woman whose secret lover sits BELOW her station
; breaks the affair FIRST to enter the january market clean; the jilted
; clerk's pressure stack is identical either way.
; ----------------------------------------------------------------------------

(npc-think jilt_for_station
  (sim-window-think)
  (rng-stream marriages)

  ; An un-betrothed, unmarried lover-holder of marriageable standing - the
  ; market is open to them the moment the affair ends. decorum-weighted:
  ; the proper feel the impropriety of the mismatch most keenly.
  (role @self 
                (believes {@self lover ?})
                (not (believes {@self fiancee ?}))
                (not (believes {@self spouse ?})))
  ; The lover beneath the jilter's station (at least one class below).
  (role ?jilted (any_human ?jilted)
                (believes {@self lover ?jilted})
                ;; @self reads the jilted lover's class from his OWN belief about him
                ;; (he knows his lover intimately, so it is banded in).
                (or (and (believes {@self class_situation [k upper]})
                         (not (believes {?jilted class_situation [k upper]})))
                    (and (believes {@self class_situation [k middle]})
                         (believes {?jilted class_situation [k lower]})))
                (select (policy first-match)))

  ;; chance gate moved here from the @self role (non-belief gate). decorum is a
  ;; DERIVED conduct dimension (belief) read from @self's own mind via
  ;; (target {...}). An unread dimension contributes 0; the +0.3 base keeps the
  ;; event alive for the un-derived.
  (when (chance (* (crime-scale) 0.15 (+ 0.3 (target {@self decorum})))))

  (cont-fire-effects
    (end-belief @self lover ?jilted)
    (incident-anchor @self jilt ?jilted)
    (nudge-stance ?jilted @self warmth -0.4)
    ))
