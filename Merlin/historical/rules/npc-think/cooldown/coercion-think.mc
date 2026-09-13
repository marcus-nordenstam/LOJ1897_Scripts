; ----------------------------------------------------------------------------
; coercion.hs - the repeat-demand loop (see Docs/hsim/hsim_crime.md "Blackmail /
; coercion").
;
; PURE .hs (no C++ generator). An actor holding a standing coercion anchor
; ({@self extort X /aux <demand>}, the ONGOING verb state the silence_coerce
; perpetration terminal mints - the `coerce` TASK label commits as a
; point-interval act-record and would never read back as standing) re-presses
; the demand monthly. The ?victim role has NO reducer, so the rule fires once
; per standing anchor - the multi-anchor walk the old C++ pass hand-rolled.
; Per anchor:
;   - a dead victim ends the matter;
;   - a RELATIONSHIP demand (the anchor carries a demand clause) is MET when
;     the victim now holds the lover or fiancee bond toward the actor (the
;     coerced match - a substrate scar, no crime): the anchor ends. The
;     demand-met read enters the victim's mind - the coerced bond is the
;     visible outcome the coercer is watching for;
;   - a demand-LESS (silence) coercion eventually loses its heat (0.10/month);
;   - spent leverage (the victim's other liaisons are already known to him)
;     ends the matter;
;   - otherwise the demand is pressed: refresh the victim's exposure-risk and
;     ride the anonymous blackmail note down the covert letter channel.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think coercion
  (cooldown 1 m)
  (rng-stream perpetration)

  (role @self )
  ; One firing per standing anchor: no (select ...) / (select (policy first-match)).
  (role ?victim {?victim isa [k human], condition [k alive]}
    {@self extort ?victim})

  (role ?my-home {@self home ?my-home})
  (role ?my-out-box [k outgoing-mail-stack] (spatial ?my-out-box building ?my-home))
  (effects
    ; The anchor's demand rides its AUX clause; no clause = a silence coercion.
    (tolerate (is-clause (any {@self extort ?victim}).auxiliary)): ?demand
    (cond
      (case {?victim condition [k dead]}
        (end-belief {@self extort ?victim}))
      ; Either bond satisfies a relationship demand. @self reads his OWN belief
      ; about the bond - formed by courting, consummation or being told - never
      ; the victim's mind.
      (case (and ?demand (any {?victim lover|fiancee @self}))
        (end-belief {@self extort ?victim}))
      ; A silence coercion lapses of itself, one month in ten.
      (case (and (not ?demand) (chance 0.10))
        (end-belief {@self extort ?victim}))
      ; Leverage is spent once the blackmailer already knows of the victim's OTHER
      ; liaisons (per-observer chastity: (count (every {?victim lover ? /ever})) counts
      ; the victim's affairs THIS mind holds - excluding its own dyad, which is {@self
      ; lover ?victim}, a different subject). If she is already known-unchaste to him,
      ; threatening to expose their affair no longer bites.
      (case (>= (count (every {?victim lover ? /ever})) 1)
        (end-belief {@self extort ?victim}))
      (else
        ; Refresh the standing extort anchor in the victim's mind (his renewed demand,
        ; perceived); the victim's coercion_pressure rule compounds the pressure off
        ; it. No act-record on a mere refresh - the anchor carries the demand. Half the
        ; months the anonymous blackmail note rides the covert letter channel - a
        ; DEDICATED kind so a campaign cannot exhaust the conspiracy-letter cache cap
        ; and a detective can tell the papers apart.
        (begin-belief ?victim {@self extort ?victim})
        (if (chance 0.5)
            (then (send-covert-letter ?victim
                                      (nl-written-msg "I coerced ?victim into becoming my lover")
                                      [k blackmail-note] ?my-out-box)))))))
