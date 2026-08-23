; ----------------------------------------------------------------------------
; contentment (classifier) - the CIRCUMSTANTIAL BASELINE of mood valence, minted
; as the {@self contentment <0..1 float>} dim from personality (enthusiasm up,
; withdrawal down), material standing (wealth), social embedding (belonging),
; drinking (sobriety shortfall + craving) and employment. In interactive sim the
; emotion model's derive_mood overlays this tick-by-tick when live emotions exist;
; here it is the baseline a mind returns to. Gated on wealth being derived (the
; adult-derive admission).
; ----------------------------------------------------------------------------

(define-macro contentment-neutral ()          0.50)
(define-macro contentment-affect-weight ()    0.26)   ; enthusiasm up, withdrawal (mirrored) down
(define-macro contentment-wealth-div ()       3)      ; (wealth - 0.5) / this
(define-macro contentment-belonging-div ()    5)      ; (belonging - 0.5) / this
(define-macro contentment-drink-weight ()    -0.5)    ; x the sobriety shortfall below 0.5
(define-macro contentment-craving-penalty () -0.12)   ; standing addiction depressor
(define-macro contentment-jobless-penalty () -0.08)   ; no job

(npc-think classify_contentment
  ; Monthly cooldown: contentment folds the continuously-drifting (sobriety) (intoxication attr)
  ; and (belonging) reads alongside wealth and the kin/employ beliefs, so a periodic recompute
  ; tracks that drift. Gated on wealth being derived; self-primed by cold_start_window.
  (cooldown 1 m)
  (rng-stream behaviour)

  (role @self {@self wealth ?wealth})

  (effects
    (begin-belief {@self contentment
      (clamp (+ (contentment-neutral)
                (* (- (attr @self enthusiasm) 0.5) (contentment-affect-weight))
                (* (- 0.5 (attr @self withdrawal)) (contentment-affect-weight))
                (/ (- ?wealth 0.5) (contentment-wealth-div))
                (/ (- (belonging) 0.5) (contentment-belonging-div))
                (* (max (- 0.5 (sobriety)) 0) (contentment-drink-weight))
                (* (prob {@self craving ?}) (contentment-craving-penalty))
                (* (- 1 (prob {@self job ?}))
                   (contentment-jobless-penalty)))
             0 1)})))
