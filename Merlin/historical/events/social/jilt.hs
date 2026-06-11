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
; The incident-anchor mints {?jilter jilt ?jilted} in BOTH minds; the patient
; cascade (Tasks.mon: abandonment_act + wrong_act) mints grief +
; attachment_loss + status_loss + anger + humiliation + injustice in the
; jilted - the exact pressure stack the new (affinity attachment_loss coerce)
; deliberation row reads on later ticks. Warmth curdles via nudge-stance;
; attraction is deliberately NOT nudged down - longing persists.
;
; Tuning knobs: the (chance 0.6) jilt-on-betrothal probability. A stance-decay
; jilt form (the bond simply cools, no betrothal) is a deferred knob - add a
; sibling event gated on (not (stance-at-least ?jilter ?jilted fancy)) when
; the distribution wants it.
;
; Schedule: monthly - a betrothed affair-holder breaks with the lover within
; a couple of months of the (annually january) betrothal.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event jilt
  (nl         "?jilter jilts ?jilted")
  (kind       _jilt)
  (schedule   (monthly))
  (band      afternoon)
  (rng-stream marriages)

  (roles
    ; The jilter: holds BOTH a lover bond and a betrothal (to someone else -
    ; the ?jilted filters enforce the third party).
    (role ?jilter (template any_human)
                  (believes ?jilter {@self lover ?})
                  (believes ?jilter {@self fiancee ?})
                  (chance 0.6))
    ; The jilted: the jilter's lover who is NOT the jilter's fiancee (the
    ; two-bound believes shape wedding.hs uses to recover the groom).
    (role ?jilted (template any_human)
                  (not (= ?jilted ?jilter))
                  (believes ?jilter {@self lover ?jilted})
                  (not (believes ?jilter {@self fiancee ?jilted}))))

  ;; Live re-check: an earlier firing this tick may already have ended the
  ;; jilter's lover bond (one jilt per jilter per tick).
  (when (believes ?jilter {@self lover ?jilted}))

  (effects
    ; One-sided ending - ONLY the jilter's belief (see header).
    (end-belief ?jilter lover ?jilted)
    ; The act-record in both minds + the appraisal cascade in each.
    (incident-anchor ?jilter jilt ?jilted)
    ; Warmth curdles; attraction is NOT touched (longing persists).
    (nudge-stance ?jilted ?jilter warmth -0.4)
    (log _jilt ?jilter)))

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

(hsim-event jilt_for_station
  (nl         "?jilter breaks with ?jilted to keep their station")
  (kind       _jilt)
  (schedule   (monthly))
  (band      afternoon)
  (rng-stream marriages)

  (roles
    ; An un-betrothed, unmarried lover-holder of marriageable standing - the
    ; market is open to them the moment the affair ends. decorum-weighted:
    ; the proper feel the impropriety of the mismatch most keenly.
    (role ?jilter (template any_human)
                  (believes ?jilter {@self lover ?})
                  (not (believes ?jilter {@self fiancee ?}))
                  (not (believes ?jilter {@self spouse ?}))
                  ;; decorum is a DERIVED conduct dimension (belief), not an
                  ;; env attr - read it through the situation op. An unread
                  ;; dimension contributes 0; the +0.3 base keeps the event
                  ;; alive for the un-derived.
                  (chance (* 0.15 (+ 0.3 (situation ?jilter decorum)))))
    ; The lover beneath the jilter's station (at least one class below).
    (role ?jilted (template any_human)
                  (not (= ?jilted ?jilter))
                  (believes ?jilter {@self lover ?jilted})
                  (or (and (= (situation ?jilter class_situation) upper)
                           (not (= (situation ?jilted class_situation) upper)))
                      (and (= (situation ?jilter class_situation) middle)
                           (= (situation ?jilted class_situation) lower)))))

  (when (believes ?jilter {@self lover ?jilted}))

  (effects
    (end-belief ?jilter lover ?jilted)
    (incident-anchor ?jilter jilt ?jilted)
    (nudge-stance ?jilted ?jilter warmth -0.4)
    (log _jilt ?jilter)))
