; ----------------------------------------------------------------------------
; appraisal.mc - the tables the engine's appraisal and memory read after the
; corpus load (load_appraisal_tables): the signal dims and their bands, the
; default salience per clock, and the identity-bearing belief labels.
; ----------------------------------------------------------------------------

(define-list salience_tuning
  default-salience-realtime  1440
  default-salience-jump     43200)

; The stance dims MUST be the first rows, in warmth/esteem/trust/attraction/dread/care order
; (the t_stance_dim enum contract). A feeling holds until felt again: one experience of
; strength |felt| pulls it toward its pole by rate x stiffness x |felt|, times negativity when
; the experience is negative. th0..th2: band thresholds, 0 = absent.
(define-table signal_dim (fields dim range rate negativity th0 th1 th2)
  (record warmth     signed   0.2 1.5 0.20 0.60 0)
  (record esteem     signed   0.2 1.5 0.20 0.60 0)
  (record trust      signed   0.2 1.5 0.20 0.60 0)
  (record attraction unsigned 0.2 1.5 0.20 0.60 0.85)
  (record dread      unsigned 0.2 1.5 0.20 0.60 0.85)
  (record care       signed   0.2 1.5 0.20 0.60 0))

; Per-dim band verbs: neg level -1,-2; pos level +1..+3; `_` = absent.
(define-table signal_verbs (fields dim neg0 neg1 pos0 pos1 pos2)
  (record warmth     dislike  detest  like    adore  _)
  (record esteem     disdain  despise admire  revere _)
  (record trust      distrust mistrust trust  rely   _)
  (record attraction _        _       fancy   desire crave)
  (record dread      _        _       wary    dread  terror)
  (record care       begrudge hate    cherish love   _))

; A feeling that barely moves while @self holds {@self <relation> target}: an experience on
; dim moves it by stiffness of its step (the least of the relations held).
(define-table stance_stiffness (fields relation dim stiffness)
  (record child  care 0.2)
  (record mother care 0.2)
  (record spouse care 0.2))

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
  (record class-situation 0.6 _)
  (record nationality  0.5 _)
  (record birthplace   0.4 _)
  (record home         0.4 _)
  (record pressure     0.3 _))
