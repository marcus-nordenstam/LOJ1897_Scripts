; ----------------------------------------------------------------------------
; deliberation_score_macros.hs - the deliberation scorer: the per (pressure,
; action) branch weight the (select-joint ...) in deliberate_think reduces over.
; Composed from atomic reads (the retired C++ (deliberation-score) op): intensity
; x affinity x trait-tilt x mood-tilt x justify x lethal x crime-scale, gated to 0
; for a self-aimed aggression or a material-less expose. disinhibition + the
; kind-match live in deliberate_think. Split from deliberation_macros.hs to keep
; each file under the parser's per-file token budget.
; ----------------------------------------------------------------------------

; Per-dimension centered swing: swing * (2v - 1), v the 0..1 reading (raw for
; trait self-beliefs / attrs; clamped for the transient mood dims).
(define-macro delib-ctr  (?v ?swing) (* ?swing (- (* 2 ?v) 1)))
(define-macro delib-ctrc (?v ?swing) (* ?swing (- (* 2 (clamp ?v 0 1)) 1)))

; The crime-deliberation action buckets. An action in none biases neutrally.
(define-macro is-aggressive (?a)
  (or (= ?a kill) (or (= ?a coerce) (or (= ?a expose) (or (= ?a threaten)
  (or (= ?a humiliate) (or (= ?a frame) (or (= ?a hurt) (or (= ?a seduce)
  (= ?a silence_witness))))))))))
(define-macro is-prosocial (?a)
  (or (= ?a forgive) (or (= ?a atone) (or (= ?a confess_in_person)
  (or (= ?a confess-letter) (or (= ?a report-crime) (= ?a do_nothing)))))))
(define-macro is-passive (?a)
  (or (= ?a withdraw) (or (= ?a flee) (or (= ?a mourn) (or (= ?a plead)
  (or (= ?a surrender) (or (= ?a replace) (= ?a expose_first))))))))

; Per-category trait tilt sums (dark tetrad via env attr; Big Five aspects via
; the self-mirrored belief, absent -> 0.5 population mean). Signs match the
; retired (trait-bias ...) rows: aggression amplifies with dark traits +
; volatility, damps with politeness + compassion; prosocial inverts; passive
; rides withdrawal against assertiveness.
(define-macro agg-trait-sum ()
  (- (+ (delib-ctr (attr @self narcissism)          (k-trait-swing))
     (+ (delib-ctr (attr @self machiavellianism)    (k-trait-swing))
     (+ (delib-ctr (attr @self psychopathy)         (k-trait-swing))
     (+ (delib-ctr (attr @self sadism)              (k-trait-swing))
        (delib-ctr (target-or @self volatility 0.5) (k-trait-swing))))))
     (+ (delib-ctr (target-or @self politeness 0.5) (k-trait-swing))
        (delib-ctr (target-or @self compassion 0.5) (k-trait-swing)))))
(define-macro pro-trait-sum ()
  (- (+ (delib-ctr (target-or @self politeness 0.5) (k-trait-swing))
        (delib-ctr (target-or @self compassion 0.5) (k-trait-swing)))
     (+ (delib-ctr (target-or @self volatility 0.5) (k-trait-swing))
     (+ (delib-ctr (attr @self narcissism)          (k-trait-swing))
     (+ (delib-ctr (attr @self machiavellianism)    (k-trait-swing))
     (+ (delib-ctr (attr @self psychopathy)         (k-trait-swing))
        (delib-ctr (attr @self sadism)              (k-trait-swing))))))))
(define-macro pas-trait-sum ()
  (- (delib-ctr (target-or @self withdrawal 0.5)    (k-trait-swing))
     (delib-ctr (target-or @self assertiveness 0.5) (k-trait-swing))))

; Per-category mood tilt sums (the transient overlay; smaller swing).
(define-macro agg-mood-sum ()
  (- (+ (delib-ctrc (target-or @self stress 0.5)    (k-mood-swing))
        (delib-ctrc (target-or @self agitation 0.5) (k-mood-swing)))
     (delib-ctrc (target-or @self contentment 0.5)  (k-mood-swing))))
(define-macro pro-mood-sum ()
  (- (delib-ctrc (target-or @self contentment 0.5)  (k-mood-swing))
     (+ (delib-ctrc (target-or @self stress 0.5)    (k-mood-swing))
        (delib-ctrc (target-or @self agitation 0.5) (k-mood-swing)))))
(define-macro pas-mood-sum ()
  (delib-ctrc (target-or @self stress 0.5) (k-mood-swing)))

; The 1.0-centered dispositional / mood multipliers, clamped to [0, 2].
(define-macro trait-tilt (?a)
  (if (is-aggressive ?a) (then (clamp (+ 1 (agg-trait-sum)) 0 2))
  (else (if (is-prosocial ?a) (then (clamp (+ 1 (pro-trait-sum)) 0 2))
  (else (if (is-passive ?a) (then (clamp (+ 1 (pas-trait-sum)) 0 2))
  (else 1)))))))
(define-macro mood-tilt (?a)
  (if (is-aggressive ?a) (then (clamp (+ 1 (agg-mood-sum)) 0 2))
  (else (if (is-prosocial ?a) (then (clamp (+ 1 (pro-mood-sum)) 0 2))
  (else (if (is-passive ?a) (then (clamp (+ 1 (pas-mood-sum)) 0 2))
  (else 1)))))))

; A held rationalisation about ?focus compounds harmful-action weight. The
; narrative is the target (wildcard) and the focus is the aux (4th slot).
(define-macro justify-factor (?focus)
  (+ 1 (* (k-justify-per) (prob {@self justify ? ?focus}))))

; Nobody murders over a hand of whist: a kill is concentrated on the lethal-
; disposed (a linear ramp on mean(psychopathy, sadism), clamped) and damped by
; the gravity of the contested prize off the pressure's act cause.
(define-macro prize-damp (?pressure)
  (if (is-a (pressure-prize ?pressure) [k game])  0.02
  (if (is-a (pressure-prize ?pressure) [k sport]) 0.25  1)))
(define-macro lethal-factor (?a ?pressure)
  (if (= ?a kill)
      (then (* (clamp (+ 1 (* 1.6 (- (lethal-disposition @self) 0.5))) 0.25 1.8)
               (prize-damp ?pressure)))
      (else 1)))

; The master crime throttle: every aggressive-category action plus the two
; non-aggressive crimes (steal / bribe).
(define-macro crime-factor (?a)
  (if (or (is-aggressive ?a) (or (= ?a steal) (= ?a bribe)))
      (then (crime-scale)) (else 1)))

; Hard gates as 0/1 score factors (a 0 drops the pair in the reducer): an
; other-directed aggression never aims at the self; an expose needs known
; discreditable material about the focus.
(define-macro self-focus-ok (?a ?focus)
  (if (and (is-aggressive ?a) (= ?focus @self)) (then 0) (else 1)))
(define-macro secret-material-ok (?a ?focus)
  (if (= ?a expose)
      (then (if (> (prob {?focus lover|HAVE-SEX-WITH ? /ever}) 0) (then 1) (else 0)))
      (else 1)))

; The full per-branch weight (excludes disinhibition + the kind-match, applied
; in deliberate_think). A non-positive result drops the pair.
(define-macro deliberation-score (?pressure ?action ?focus ?weight)
  (* (pressure-intensity ?pressure)
     (* ?weight
     (* (trait-tilt ?action)
     (* (mood-tilt ?action)
     (* (justify-factor ?focus)
     (* (lethal-factor ?action ?pressure)
     (* (crime-factor ?action)
     (* (self-focus-ok ?action ?focus)
        (secret-material-ok ?action ?focus))))))))))

; ----------------------------------------------------------------------------
; Routine-drive personality tilts (NOT pressure-deliberation) - the disposition
; scaling the WORSHIP / work drive utilities carry, reusing the centered-swing
; helpers above. Ported from the retired C++ category_drive_modifier: worship
; rises with politeness (respect for convention), work with industriousness and
; falls with stress (the stressed shirk). Applied in-band in each drive rule's
; (utility), so a diligent / devout NPC out-ranks a shirker / lapsed one.
; ----------------------------------------------------------------------------
(define-macro devotional-drive-tilt ()
  (clamp (+ 1 (delib-ctr (attr @self politeness) (k-drive-trait-swing))) 0 2))
(define-macro labour-drive-tilt ()
  (* (clamp (+ 1 (delib-ctr (attr @self industriousness) (k-drive-trait-swing))) 0 2)
     (clamp (+ 1 (delib-ctrc (target-or @self stress 0.5) (- 0 (k-drive-mood-swing)))) 0 2)))
