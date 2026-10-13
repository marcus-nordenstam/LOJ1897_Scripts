; ----------------------------------------------------------------------------
; mobilisation - how strongly @self is roused over a wrong done to someone else: how warmly he
; stands toward them (the strongest warmth verb he ever held first), how close he is to them,
; and how much justice weighs with him. A third-party reaction scales its pressure by it.
; ----------------------------------------------------------------------------

(define-func mobilisation-scale (?patient)
  (bind (cond
          (case {@self adore ?patient /ever} 1.0)
          (case {@self like ?patient /ever} 0.70)
          (case {@self dislike ?patient /ever} 0.12)
          (case {@self detest ?patient /ever} 0.05)
          (else 0.30)) ?warmth)
  (bind (flip {@self (closeness-labels close_friend) ?patient /ever} 2.0 1.0) ?closeness)
  (any {@self compassion ?compassion=0.5})
  (bind (+ 0.35 (* (- 1.0 0.35) ?compassion)) ?justice)
  (flip (is-object ?patient)
        (clamp (* (* ?justice ?warmth) ?closeness) 0.0 1.25)
        1.0))
