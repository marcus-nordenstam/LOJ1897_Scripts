; Per-dimension centered swing: swing * (2v - 1), v the 0..1 reading (raw for
; trait self-beliefs / attrs; clamped for the transient mood dims).
(define-func delib-ctr (?v ?swing)
  (* ?swing (- (* 2.0 ?v) 1.0)))

(define-func delib-ctrc (?v ?swing)
  (* ?swing (- (* 2.0 (clamp ?v 0.0 1.0)) 1.0)))

; How hard this grievance pushes toward one class of outlet, before that outlet's own
; base weight: the grievance's heat, the caller's class multiplier (its aggressive-tilt /
; prosocial-tilt, or 1 for an outlet no disposition steers), and the compounding a held
; rationalisation about the focus adds (its narrative is the target, the focus the aux).
(define-func grievance-drive (?pressure ?focus ?tilt)
  (* (pressure-intensity ?pressure)
     (* ?tilt (+ 1.0 (* (k-justify-per) (prob {@self justify ? ?focus}))))))
