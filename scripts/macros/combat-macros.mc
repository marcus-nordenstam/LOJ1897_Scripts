; A whiffing attacker is easier to slip: a clean miss posts `whiffed` on the
; attacker (publicly observable), read by the flee roll as a recent-clumsiness bonus.
(define-macro whiff_ttl_cycles () 3)

; A sustained kill-assault finally tells: a LANDED-but-non-fatal kill blow succumbs
; with this per-blow probability (the bleed-out analogue the dead bleed columns modelled).
(define-macro blow_succumb_prob () 0.25)

; The pain each blow leaves in its victim, 0 none .. 1 agony.
(define-macro punch_hit_pain () 0.6)

(define-macro punch_graze_pain () 0.3)

(define-macro shot_hit_pain () 1.0)

(define-macro shot_graze_pain () 0.8)

(define-macro strangle_hit_pain () 1.0)

(define-macro strangle_graze_pain () 0.5)
