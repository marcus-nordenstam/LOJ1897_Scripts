; ----------------------------------------------------------------------------
; contentment (classifier) - the CIRCUMSTANTIAL BASELINE of mood valence, minted
; as the {@self contentment <0..1 float>} dim from personality (enthusiasm up,
; withdrawal down), material standing (wealth), social embedding (belonging),
; drinking (a lax sobriety band + craving) and employment. In interactive sim the
; emotion model's derive_mood overlays this tick-by-tick when live emotions exist;
; here it is the baseline a mind returns to. Gated on wealth being derived (the
; adult-derive admission).
; ----------------------------------------------------------------------------

(define-macro contentment-neutral ()          0.50)
(define-macro contentment-affect-weight ()    0.26)   ; enthusiasm up, withdrawal (mirrored) down
(define-macro contentment-wealth-div ()       3.0)    ; (wealth - 0.5) / this
(define-macro contentment-belonging-div ()    5.0)    ; (belonging - 0.5) / this
(define-macro contentment-lax-drink-penalty () -0.125) ; a lax sobriety band's depressor
(define-macro contentment-craving-penalty () -0.12)   ; standing addiction depressor
(define-macro contentment-jobless-penalty () -0.08)   ; no job

(think classify-contentment
  ; Monthly cooldown: contentment folds the sobriety band and belonging alongside wealth and
  ; the kin/employ beliefs, so a periodic recompute tracks their drift. Gated on wealth being derived; self-primed by cold_start_window.
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  (role @self {@self enthusiasm ?enthusiasm}
              {@self withdrawal ?withdrawal}
              {@self belonging ?belonging}
              {@self sobriety ?sobriety}
              {@self wealth ?wealth}

    ; The baseline is summed in two halves - dispositional (personality + wealth) and
    ; circumstantial (belonging, drink, employment) - bound to intermediates so neither the
    ; per-func arg count nor the per-mint pattern count of the whole sum overflows the substrate.
    (bind (+ (contentment-neutral)
             (* (- ?enthusiasm 0.5) (contentment-affect-weight))
             (* (- 0.5 ?withdrawal) (contentment-affect-weight))
             (/ (- ?wealth 0.5) (contentment-wealth-div))) ?disposition)
    (bind (+ (/ (- ?belonging 0.5) (contentment-belonging-div))
             (if (= ?sobriety [k lax]) (then (contentment-lax-drink-penalty)) (else 0.0))
             (* (prob {@self craving ?}) (contentment-craving-penalty))
             (* (- 1.0 (prob {@self job ?})) (contentment-jobless-penalty))) ?circumstance)

    (effects
      (begin-belief {@self contentment (clamp (+ ?disposition ?circumstance) 0.0 1.0)}))))
