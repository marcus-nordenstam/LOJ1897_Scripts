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
  default-salience-realtime  1440
  default-salience-jump     43200)

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
