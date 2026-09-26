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
  (bind (if {@self (closeness-labels close_friend) ?patient /ever} (then 2.0) (else 1.0)) ?closeness)
  (bind (+ 0.35 (* (- 1.0 0.35) (target-or @self compassion 0.5))) ?justice)
  (if (is-object ?patient)
      (then (clamp (* (* ?justice ?warmth) ?closeness) 0.0 1.25))
      (else 1.0)))
