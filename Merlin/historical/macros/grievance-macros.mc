; ----------------------------------------------------------------------------
; grievance-macros - the shared scoring vocabulary the pressure-response rules
; (rules/npc-think/cooldown/grievance-*.mc) compose their drive from.
;
; A standing {@self pressure <kind> /aux <focus>} belief is a grievance: something
; happened, it is directed at someone, and it has not been spent. Each response rule
; owns ONE outlet for it and reads its drive from here: how hot the grievance is
; (pressure-intensity), how far the actor's disposition tilts toward that CLASS of
; outlet (agg-tilt / pro-tilt), and whether a held rationalisation compounds it.
;
; The tilts are per-CLASS, not per-action: which class an outlet belongs to is
; settled by which macro its rule calls, so there is no action dispatch here.
; ----------------------------------------------------------------------------

; Per-dimension centered swing: swing * (2v - 1), v the 0..1 reading (raw for
; trait self-beliefs / attrs; clamped for the transient mood dims).
(define-macro delib-ctr  (?v ?swing) (* ?swing (- (* 2 ?v) 1)))
(define-macro delib-ctrc (?v ?swing) (* ?swing (- (* 2 (clamp ?v 0 1)) 1)))

; The 1.0-centered dispositional multiplier an AGGRESSIVE outlet rides: dark tetrad
; (env attr) + volatility amplify, politeness + compassion damp; the transient mood
; overlay rides a smaller swing on top. Each half clamps to [0, 2], so the product
; spans [0, 4].
(define-macro agg-tilt ()
  (* (clamp (+ 1
       (- (+ (delib-ctr (attr @self narcissism)          (k-trait-swing))
          (+ (delib-ctr (attr @self machiavellianism)    (k-trait-swing))
          (+ (delib-ctr (attr @self psychopathy)         (k-trait-swing))
          (+ (delib-ctr (attr @self sadism)              (k-trait-swing))
             (delib-ctr (target-or @self volatility 0.5) (k-trait-swing))))))
          (+ (delib-ctr (target-or @self politeness 0.5) (k-trait-swing))
             (delib-ctr (target-or @self compassion 0.5) (k-trait-swing))))) 0 2)
     (clamp (+ 1
       (- (+ (delib-ctrc (target-or @self stress 0.5)    (k-mood-swing))
             (delib-ctrc (target-or @self agitation 0.5) (k-mood-swing)))
             (delib-ctrc (target-or @self contentment 0.5) (k-mood-swing)))) 0 2)))

; The PROSOCIAL twin - the same dimensions with the signs reversed, so the polite and
; compassionate confess and report where the dark and volatile expose and coerce.
(define-macro pro-tilt ()
  (* (clamp (+ 1
       (- (+ (delib-ctr (target-or @self politeness 0.5) (k-trait-swing))
             (delib-ctr (target-or @self compassion 0.5) (k-trait-swing)))
          (+ (delib-ctr (target-or @self volatility 0.5) (k-trait-swing))
          (+ (delib-ctr (attr @self narcissism)          (k-trait-swing))
          (+ (delib-ctr (attr @self machiavellianism)    (k-trait-swing))
          (+ (delib-ctr (attr @self psychopathy)         (k-trait-swing))
             (delib-ctr (attr @self sadism)              (k-trait-swing)))))))) 0 2)
     (clamp (+ 1
       (- (delib-ctrc (target-or @self contentment 0.5)  (k-mood-swing))
          (+ (delib-ctrc (target-or @self stress 0.5)    (k-mood-swing))
             (delib-ctrc (target-or @self agitation 0.5) (k-mood-swing))))) 0 2)))

; How hard this grievance pushes toward one class of outlet, before that outlet's own
; base weight: the grievance's heat, the caller's class multiplier ((agg-tilt) /
; (pro-tilt), or 1 for an outlet no disposition steers), and the compounding a held
; rationalisation about the focus adds (its narrative is the target, the focus the aux).
(define-macro grievance-drive (?pressure ?focus ?tilt)
  (* (pressure-intensity ?pressure)
     (* ?tilt (+ 1 (* (k-justify-per) (prob {@self justify ? ?focus}))))))

; ----------------------------------------------------------------------------
; Routine-drive personality tilts (NOT grievance) - the disposition scaling the
; WORSHIP / work drive utilities carry, reusing the centered-swing helpers above.
; Worship rises with politeness (respect for convention), work with industriousness
; and falls with stress (the stressed shirk). Applied in-band in each drive rule's
; (utility), so a diligent / devout NPC out-ranks a shirker / lapsed one.
; ----------------------------------------------------------------------------
(define-macro devotional-drive-tilt ()
  (clamp (+ 1 (delib-ctr (attr @self politeness) (k-drive-trait-swing))) 0 2))
(define-macro labour-drive-tilt ()
  (* (clamp (+ 1 (delib-ctr (attr @self industriousness) (k-drive-trait-swing))) 0 2)
     (clamp (+ 1 (delib-ctrc (target-or @self stress 0.5) (- 0 (k-drive-mood-swing)))) 0 2)))
