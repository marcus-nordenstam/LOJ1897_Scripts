; ----------------------------------------------------------------------------
; feelings - how a feeling arises: how strongly it is felt when it is minted, and the mint.
;
; A feeling's salience is its authored base (hours) scaled by the mood the mind is in and by
; the traits that bend feelings of its kind. An emotion consolidates - its strength stamps
; the memories behind and around it; a pressure does not. A pressure whose every cause is
; forgotten has no psychological reality and ends before a new one is minted.
; ----------------------------------------------------------------------------

(define-macro max-emotion-salience () 336.0)
(define-macro max-pressure-salience () 8760.0)
(define-macro mood-salience-gain () 0.5)

; How a trait bends a feeling of this kind: 1 + gain x (trait - 0.5); a one-sided row (the dark
; tetrad) only above the mean, since low sadism is ordinary aversion, not a bonus. A negative
; gain dampens.
(define-table trait_affect (fields trait kind gain one-sided)
  (record volatility  [k anger]           0.8 0)
  (record volatility  [k fear]            0.8 0)
  (record volatility  [k distress]        0.8 0)
  (record volatility  [k jealousy]        0.8 0)
  (record withdrawal  [k grief]           0.8 0)
  (record withdrawal  [k fear]            0.8 0)
  (record withdrawal  [k shame]           0.8 0)
  (record withdrawal  [k guilt]           0.8 0)
  (record enthusiasm  [k joy]             0.6 0)
  (record enthusiasm  [k hope]            0.6 0)
  (record enthusiasm  [k pride]           0.6 0)
  (record enthusiasm  [k gratitude]       0.6 0)
  (record enthusiasm  [k affection]       0.6 0)
  (record enthusiasm  [k relief]          0.6 0)
  (record narcissism  [k humiliation]     1.2 1)
  (record narcissism  [k injustice]       1.2 1)
  (record narcissism  [k shame]           1.2 1)
  (record narcissism  [k anger]           1.2 1)
  (record narcissism  [k contempt]        1.2 1)
  (record psychopathy [k guilt]          -0.6 1)
  (record psychopathy [k fear]           -0.6 1)
  (record psychopathy [k moral-violation] -0.6 1))

(define-func trait-factor (?kind ?trait ?value)
  (if (table-match trait_affect trait ?trait kind ?kind gain ?g one-sided ?one)
      (then (+ 1.0 (* ?g (if (= ?one 1)
                             (then (max (- ?value 0.5) 0.0))
                             (else (- ?value 0.5))))))
      (else 1.0)))

; The salience a feeling of ?kind is felt with, from its authored base in hours.
(define-func feeling-salience (?kind ?hours)
  (bind (+ 1.0 (* (clamp (target-or @self agitation 0.0) 0.0 1.0) (mood-salience-gain))) ?mood)
  (bind (* (* (* (* (trait-factor ?kind volatility (target-or @self volatility 0.5))
                    (trait-factor ?kind withdrawal (target-or @self withdrawal 0.5)))
                 (trait-factor ?kind enthusiasm (target-or @self enthusiasm 0.5)))
              (trait-factor ?kind narcissism (target-or @self narcissism 0.5)))
           (trait-factor ?kind psychopathy (target-or @self psychopathy 0.5))) ?traits)
  (floor (+ (clamp (* ?hours (* ?mood ?traits))
                   1.0
                   (max (max-emotion-salience) (max-pressure-salience)))
            0.5)))

; An emotion over ?cause, a belief; @nothing is the act the reflex dispatching it construes.
(define-func mint-emotion-caused (?kind ?focus ?hours ?cause)
  (mint-feeling emotion ?kind ?focus (feeling-salience ?kind ?hours) (max-emotion-salience) @true
                ?cause))

(define-func mint-emotion (?kind ?focus ?hours)
  (mint-emotion-caused ?kind ?focus ?hours @nothing))

(define-func mint-pressure (?kind ?focus ?hours)
  (end-where ?orphan {@self pressure ? ?} (not (has-live-cause ?orphan)))
  (mint-feeling pressure ?kind ?focus (feeling-salience ?kind ?hours) (max-pressure-salience) @false
                @nothing))
