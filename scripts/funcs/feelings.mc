; ----------------------------------------------------------------------------
; feelings - how a feeling arises: how strongly it is felt when it is minted, and the mint.
;
; A feeling's salience is its authored base (hours) scaled by the mood the mind is in and by
; the traits that bend feelings of its kind. An emotion consolidates - its strength stamps
; the memories behind and around it; a pressure does not. A pressure whose every cause is
; forgotten has no psychological reality and ends before a new one is minted.
; ----------------------------------------------------------------------------


; How a trait bends a feeling of this kind, felt over an act of this construed category (`_` =
; over anything): the felt hours become hours x (1 + gain x lean) + offset x lean, the lean being
; trait - 0.5, or only its excess above the mean on a one-sided row (the dark tetrad: low sadism
; is ordinary aversion, not a bonus). A negative gain dampens; an offset can raise a feeling from
; nothing or drive one to nothing - the sadist's relish where others feel contempt.
(define-table trait_affect (fields trait kind category gain offset one-sided)
  (record volatility  [k anger]              _           0.8 0.0    0)
  (record volatility  [k fear]               _           0.8 0.0    0)
  (record volatility  [k distress]           _           0.8 0.0    0)
  (record volatility  [k jealousy]           _           0.8 0.0    0)
  (record withdrawal  [k grief]              _           0.8 0.0    0)
  (record withdrawal  [k fear]               _           0.8 0.0    0)
  (record withdrawal  [k shame]              _           0.8 0.0    0)
  (record withdrawal  [k guilt]              _           0.8 0.0    0)
  (record enthusiasm  [k joy]                _           0.6 0.0    0)
  (record enthusiasm  [k hope]               _           0.6 0.0    0)
  (record enthusiasm  [k pride]              _           0.6 0.0    0)
  (record enthusiasm  [k gratitude]          _           0.6 0.0    0)
  (record enthusiasm  [k affection]          _           0.6 0.0    0)
  (record enthusiasm  [k relief]             _           0.6 0.0    0)
  (record narcissism  [k humiliation]        _           1.2 0.0    1)
  (record narcissism  [k injustice]          _           1.2 0.0    1)
  (record narcissism  [k shame]              _           1.2 0.0    1)
  (record narcissism  [k anger]              _           1.2 0.0    1)
  (record narcissism  [k contempt]           _           1.2 0.0    1)
  (record psychopathy [k guilt]              _          -0.6 0.0    1)
  (record psychopathy [k fear]               _          -0.6 0.0    1)
  (record psychopathy [k moral-violation]    _          -0.6 0.0    1)
  (record sadism      [k contempt]           betray-act  0.0 -192.0 1)
  (record sadism      [k joy]                betray-act  0.0 30.0   1)
  (record sadism      [k pride]              betray-act  0.0 60.0   1))

; One trait_affect row applied to ?hours by a trait at ?value.
(define-func trait-felt (?hours ?gain ?offset ?one-sided ?value)
  (bind (flip (= ?one-sided 1) (max (- ?value 0.5) 0.0) (- ?value 0.5)) ?lean)
  (+ (* ?hours (+ 1.0 (* ?gain ?lean))) (* ?offset ?lean)))

; The salience a feeling of ?kind over an act of ?category (@nothing = none named) is felt with,
; from its authored base in hours: every trait_affect row for the kind and the category, by the
; trait @self holds, then the mood. Under one hour it is not felt at all.
(define-func feeling-salience (?kind ?hours ?category)
  (any {@self agitation ?agitation=0.0})
  (bind (+ /float ?hours 0.0) ?felt)
  (for-each-row trait_affect [/trait ?trait] [/kind ?row-kind] [/category ?row-category]
                             [/gain ?gain] [/offset ?offset] [/one-sided ?one-sided]
    (if (and (= ?row-kind ?kind) (trait-row-covers ?row-category ?category))
        (then
          (any {@self ?trait ?value=0.5})
          (bind (trait-felt ?felt ?gain ?offset ?one-sided ?value) ?felt))))
  (bind (+ 1.0 (* (clamp ?agitation 0.0 1.0) (mood-salience-gain))) ?mood)
  (floor (+ (clamp (* ?felt ?mood) 0.0 (max (max-emotion-salience) (max-pressure-salience))) 0.5)))

; Does a trait_affect row of ?row-category cover a feeling over ?category.
(define-func trait-row-covers (?row-category ?category)
  (flip (substantial ?row-category)
        (flip (substantial ?category) (= ?row-category ?category) @false)
        @true))

; An emotion over ?cause, a belief; @nothing is the act the reflex dispatching it construes.
(define-func mint-emotion-caused (?kind ?focus ?hours ?cause)
  (mint-emotion-felt ?kind ?focus (feeling-salience ?kind ?hours @nothing) ?cause))

(define-func mint-emotion (?kind ?focus ?hours)
  (mint-emotion-caused ?kind ?focus ?hours @nothing))

; An emotion over the act a reflex construes as ?category, which the trait_affect rows of that
; category bend.
(define-func mint-construed-emotion (?category ?kind ?focus ?hours)
  (mint-emotion-felt ?kind ?focus (feeling-salience ?kind ?hours ?category) @nothing))

(define-func mint-emotion-felt (?kind ?focus ?salience ?cause)
  (if (>= ?salience 1.0)
      (then (mint-feeling emotion ?kind ?focus ?salience (max-emotion-salience) @true ?cause))))

; A pressure over ?cause, a belief that stands while it is felt.
(define-func mint-pressure-caused (?kind ?focus ?hours ?cause)
  (bind (feeling-salience ?kind ?hours @nothing) ?salience)
  (if (>= ?salience 1.0)
      (then (mint-feeling pressure ?kind ?focus ?salience (max-pressure-salience) @false ?cause))))

(define-func mint-pressure (?kind ?focus ?hours)
  (end-where ?orphan {@self pressure ? ?} (not (has-live-cause ?orphan)))
  (bind (feeling-salience ?kind ?hours @nothing) ?salience)
  (if (>= ?salience 1.0)
      (then (mint-feeling pressure ?kind ?focus ?salience (max-pressure-salience) @false @nothing))))
