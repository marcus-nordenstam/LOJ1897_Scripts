; ----------------------------------------------------------------------------
; appraisal.mc - the tables the engine's appraisal and memory read after the
; corpus load (load_appraisal_tables): the signal dims and their bands, the
; default salience per clock, and the identity-bearing belief labels.
; ----------------------------------------------------------------------------

(define-list salience_tuning
  default-salience-realtime  1440
  default-salience-jump     43200)

; The five stance dims MUST be the first five rows, in
; warmth/esteem/trust/attraction/dread order (the t_stance_dim enum contract).
; th0..th2: band thresholds, 0 = absent.
(define-table signal_dim (fields dim range retention th0 th1 th2)
  (record warmth     signed   0.938 0.20 0.60 0)
  (record esteem     signed   0.938 0.20 0.60 0)
  (record trust      signed   0.938 0.20 0.60 0)
  (record attraction unsigned 0.938 0.20 0.60 0.85)
  (record dread      unsigned 0.99  0.20 0.60 0.85))

; Per-dim band verbs: neg level -1,-2; pos level +1..+3; `_` = absent.
(define-table signal_verbs (fields dim neg0 neg1 pos0 pos1 pos2)
  (record warmth     dislike  detest  like   adore  _)
  (record esteem     disdain  despise admire revere _)
  (record trust      distrust suspect trust  rely   _)
  (record attraction _        _       fancy  desire crave)
  (record dread      _        _       wary   dread  terror))

; A committed {@self <label> [<target>]} belief matching a row adds `weight`
; to the identity-anchor accumulator; tar filters the target kind, `_` = any.
(define-table identity_driver (fields label weight tar)
  (record mother       0.7 _)
  (record father       0.7 _)
  (record child        0.7 _)
  (record sibling      0.5 _)
  (record cousin       0.3 _)
  (record spouse       0.7 _)
  (record lover        0.5 _)
  (record friend       0.3 _)
  (record identity     1.0 _)
  (record value        0.8 _)
  (record admire       0.4 _)
  (record revere       0.4 _)
  (record job          0.6 _)
  (record social_class 0.6 _)
  (record nationality  0.5 _)
  (record birthplace   0.4 _)
  (record home         0.4 _)
  (record pressure     0.3 _))
