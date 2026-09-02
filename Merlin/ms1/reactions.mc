; ----------------------------------------------------------------------------
; reactions.mc - emotion / appraisal tuning data, as .mc define-lists/tables.
;
; Loaded by Merlin at ontology-load time (appraisal_load_norms, called from
; t_simulator::load_ontology) through the shared .mc list/table coordinator -
; the SAME parser rules and config use. Editing this file re-tunes the emotion
; model for isim AND hsim - no rebuild, no rule changes.
;
; Variable-length fields (trait_affect kinds, signal thresholds/neg/pos) use
; FIXED-max columns; `_` marks an absent slot (skipped) and 0 an absent
; threshold. The five stance dims MUST be the first five signal rows, in
; warmth/esteem/trust/attraction/dread order (the t_stance_dim enum contract).
; ----------------------------------------------------------------------------

; ---- global tuning ---------------------------------------------------------
(define-list tuning
  max-emotion-salience   336
  max-pressure-salience  8760
  mood-salience-gain     0.5
  stance-lr              0.2
  default-salience-isim  24
  default-salience-hsim  8640)

; ---- emotion affect (kind valence arousal) ---------------------------------
(define-table emotion_affect (fields kind valence arousal)
  (record joy        1.0  0.6)
  (record pride      1.0  0.5)
  (record hope       1.0  0.4)
  (record relief     1.0  0.2)
  (record gratitude  1.0  0.3)
  (record affection  1.0  0.3)
  (record grief     -1.0  0.2)
  (record distress  -1.0  0.7)
  (record anger     -1.0  0.9)
  (record fear      -1.0  0.9)
  (record shame     -1.0  0.4)
  (record guilt     -1.0  0.4)
  (record envy      -1.0  0.6)
  (record jealousy  -1.0  0.7)
  (record disgust   -1.0  0.5)
  (record contempt  -1.0  0.4)
  (record admiration 1.0  0.4)
  (record longing    0.7  0.6))

; ---- pressure affect (kind stress) -----------------------------------------
(define-table pressure_affect (fields kind stress)
  (record humiliation        0.8)
  (record existential-threat 1.0)
  (record exposure-risk      0.7)
  (record moral-violation    0.6)
  (record injustice          0.7)
  (record status-loss        0.6)
  (record attachment-loss    0.7)
  (record autonomy-loss      0.5)
  (record resource-scarcity  0.6)
  (record obligation-strain  0.4)
  (record rivalry-pressure   0.5))

; ---- trait affect (one row per (aspect, kind); grouped by aspect at load) ---
; dampens 1 negates the gain (an alias for amplifies-with-negated-gain).
(define-table trait_affect (fields aspect kind gain one-sided dampens)
  (record volatility  anger           0.8 0 0)
  (record volatility  fear            0.8 0 0)
  (record volatility  distress        0.8 0 0)
  (record volatility  jealousy        0.8 0 0)
  (record withdrawal  grief           0.8 0 0)
  (record withdrawal  fear            0.8 0 0)
  (record withdrawal  shame           0.8 0 0)
  (record withdrawal  guilt           0.8 0 0)
  (record enthusiasm  joy             0.6 0 0)
  (record enthusiasm  hope            0.6 0 0)
  (record enthusiasm  pride           0.6 0 0)
  (record enthusiasm  gratitude       0.6 0 0)
  (record enthusiasm  affection       0.6 0 0)
  (record enthusiasm  relief          0.6 0 0)
  (record narcissism  humiliation     1.2 1 0)
  (record narcissism  injustice       1.2 1 0)
  (record narcissism  shame           1.2 1 0)
  (record narcissism  anger           1.2 1 0)
  (record narcissism  contempt        1.2 1 0)
  (record psychopathy guilt           0.6 1 1)
  (record psychopathy fear            0.6 1 1)
  (record psychopathy moral-violation 0.6 1 1))

; ---- relational-signal dimensions (split: scalars+thresholds, then verbs) ---
; The five stance dims MUST be the first five signal rows, in
; warmth/esteem/trust/attraction/dread order (the t_stance_dim enum contract).
(define-table signal (fields dim range retention th0 th1 th2)
  (record warmth     signed   0.938 0.20 0.60 0)
  (record esteem     signed   0.938 0.20 0.60 0)
  (record trust      signed   0.938 0.20 0.60 0)
  (record attraction unsigned 0.938 0.20 0.60 0.85)
  (record dread      unsigned 0.99  0.20 0.60 0.85))

; per-dim band verbs (neg level -1,-2; pos level +1..+3); `_` = absent.
(define-table signal_verbs (fields dim neg0 neg1 pos0 pos1 pos2)
  (record warmth     dislike  detest  like   adore  _)
  (record esteem     disdain  despise admire revere _)
  (record trust      distrust suspect trust  rely   _)
  (record attraction _        _       fancy  desire crave)
  (record dread      _        _       wary   dread  terror))

; ---- stance coupling (emotion + weight per dim; 0 = no coupling) ------------
(define-table stance_coupling (fields emotion warmth esteem trust attraction dread)
  (record anger      -0.4 -0.1 -0.2 0 0)
  (record contempt   -0.2 -0.5  0   0 0)
  (record disgust    -0.3 -0.4  0   0 0)
  (record envy        0   -0.3  0   0 0)
  (record jealousy   -0.3  0   -0.2 0 0)
  (record fear       -0.2  0   -0.3 0 0.6)
  (record gratitude   0.4  0    0.2 0 0)
  (record affection   0.5  0    0   0 0)
  (record admiration  0.2  0.5  0   0 0))

; ---- conduct stance (dim esteem warmth trust vice) -------------------------
(define-table conduct_stance (fields dim esteem warmth trust vice)
  (record honesty     0.25 0.10 0.40 0)
  (record piety       0.30 0.15 0.05 0)
  (record sobriety    0.20 0.10 0.10 0)
  (record decorum     0.25 0.20 0.05 0)
  (record criminality 0.40 0.30 0.50 1))

; ---- kin / third-party mobilisation (verb weight) --------------------------
(define-table mobilisation (fields verb weight)
  (record adore   1.00)
  (record like    0.70)
  (record dislike 0.12)
  (record detest  0.05))

; ---- Class II standing weights ---------------------------------------------
(define-list standing
  lr                    0.15
  centrality-gate       3
  stride                4
  budget                4096
  caring-base           0.4
  class-mismatch-warmth 0.20
  class-match-warmth    0.08
  rival-warmth          0.30
  rival-esteem          0.15
  envy-esteem           0.30
  envy-gap-min          0.15
  transitive-warmth     0.25
  attr-lr               0.40
  attr-min-age          16
  attr-looks-male       0.70
  attr-looks-female     0.35
  attr-status-male      0.20
  attr-status-female    0.55
  attr-agegap-penalty   0.50)
