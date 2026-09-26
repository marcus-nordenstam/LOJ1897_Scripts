; ----------------------------------------------------------------------------
; mood - felt life, settled once a night from the day's feelings.
;
; contentment is the valence and agitation the arousal of the live emotions, each weighted
; by how strongly it is still felt; stress is the load of the live pressures. A feeling that
; has faded out ends here, and so does a pressure whose every cause is forgotten. With
; no live emotion the contentment / agitation pair is left alone (the contentment
; classifier's circumstantial baseline stands), and with no live pressure so is stress.
; ----------------------------------------------------------------------------

; How pleasant (valence -1..1) and how rousing (arousal 0..1) each emotion is.
(define-table emotion_affect (fields kind valence arousal)
  (record [k joy]         1.0  0.6)
  (record [k pride]       1.0  0.5)
  (record [k hope]        1.0  0.4)
  (record [k relief]      1.0  0.2)
  (record [k gratitude]   1.0  0.3)
  (record [k affection]   1.0  0.3)
  (record [k grief]      -1.0  0.2)
  (record [k distress]   -1.0  0.7)
  (record [k anger]      -1.0  0.9)
  (record [k fear]       -1.0  0.9)
  (record [k shame]      -1.0  0.4)
  (record [k guilt]      -1.0  0.4)
  (record [k envy]       -1.0  0.6)
  (record [k jealousy]   -1.0  0.7)
  (record [k disgust]    -1.0  0.5)
  (record [k contempt]   -1.0  0.4)
  (record [k admiration]  1.0  0.4)
  (record [k longing]     0.7  0.6))

; How much stress each pressure loads.
(define-table pressure_affect (fields kind stress)
  (record [k humiliation]        0.8)
  (record [k existential-threat] 1.0)
  (record [k exposure-risk]      0.7)
  (record [k moral-violation]    0.6)
  (record [k injustice]          0.7)
  (record [k status-loss]        0.6)
  (record [k attachment-loss]    0.7)
  (record [k autonomy-loss]      0.5)
  (record [k resource-scarcity]  0.6)
  (record [k obligation-strain]  0.4)
  (record [k rivalry-pressure]   0.5))

(define-func emotion-valence (?kind)
  (if (table-match emotion_affect kind ?kind valence ?v) (then ?v) (else 0.0)))

(define-func emotion-arousal (?kind)
  (if (table-match emotion_affect kind ?kind arousal ?a) (then ?a) (else 0.0)))

(define-func pressure-stress (?kind)
  (if (table-match pressure_affect kind ?kind stress ?s) (then ?s) (else 0.0)))

; A mood value is kept to hundredths.
(define-func mood-grain (?x)
  (* (floor (+ (* ?x 100.0) 0.5)) 0.01))

(define-func /sleep settle-mood ()
  (end-where ?p {@self pressure ? ?} (not (has-live-cause ?p)))
  (end-where ?p {@self pressure ? ?} (<= (pressure-intensity ?p) 0.0))
  (end-where ?e {@self emotion ? ?} (<= (emotion-intensity ?e) 0.0))
  (bind (sum-over ?p {@self pressure ?kind ?}
          (if (has-live-cause ?p)
              (then (* (pressure-intensity ?p) (pressure-stress ?kind)))
              (else 0.0))) ?stress)
  (bind (sum-over ?e {@self emotion ? ?} (emotion-intensity ?e)) ?felt)
  (if (> ?stress 0.0)
      (then (set-self-state stress (mood-grain (clamp ?stress 0.0 1.0)))))
  (if (> ?felt 0.0)
      (then
        (set-self-state contentment
          (mood-grain (* (+ (/ (sum-over ?e {@self emotion ?kind ?}
                                  (* (emotion-intensity ?e) (emotion-valence ?kind)))
                               ?felt)
                            1.0)
                         0.5)))
        (set-self-state agitation
          (mood-grain (/ (sum-over ?e {@self emotion ?kind ?}
                            (* (emotion-intensity ?e) (emotion-arousal ?kind)))
                         ?felt))))))
