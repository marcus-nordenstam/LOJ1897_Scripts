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
;   - otherwise (press-coercion ?victim) (coercion_macros.hs): end on spent
;     leverage, else refresh the victim's exposure_risk and ride the
;     anonymous blackmail note down the covert letter channel.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think coercion
  (cooldown 1 m)
  (rng-stream perpetration)

  (role @self )
  ; One firing per standing anchor: no (select ...) / (select (policy first-match)).
  (role ?victim (any_human ?victim)
    {@self extort ?victim})

  (effects
    (if {?victim condition [k dead]}
        (then (end-belief {@self extort ?victim}))
        (else
          ; The anchor's demand rides its AUX clause; no clause = a silence
          ; coercion.
          (if (is-clause (any {@self extort ?victim}).auxiliary)
              ; Either bond satisfies a relationship demand.
              (then (if (or (believes ?victim {?victim lover @self})
                      (believes ?victim {?victim fiancee @self}))
                  (then (end-belief {@self extort ?victim}))
                  (else (press-coercion ?victim))))
              (else (if (chance 0.10)
                  (then (end-belief {@self extort ?victim}))
                  (else (press-coercion ?victim)))))))))
