; ----------------------------------------------------------------------------
; combat.mc - the physics of a blow, shared by the violent actions PUNCH / SHOOT /
; STRANGLE: the roll, the pain and the wounds it leaves, and the fatal physics. Which blow
; to deal is the driving TASK's choice; blame lives on that task and the runtime-blame
; gate, never on the neutral blow.
; ----------------------------------------------------------------------------

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

; (land-blow): ONE roll of the striker's own body - adrenaline surges, and strength,
; dexterity and drink decide whether the blow lands (hit), glances (graze) or misses. A
; miss posts `whiffed` on the striker. Answers hit / graze / miss.
(define-func land-blow ()
  (set-attr @self adrenaline 1)
  (clamp (+ 0.45
            (* 0.30 (- (attr @self strength) 0.5))
            (* 0.40 (- (attr @self dexterity) 0.5))
            (* -1.2 (attr @self intoxication)))
         0.02 0.98): ?p
  (rng-unit): ?u
  (if (>= ?u (+ ?p 0.30))
      (then (bb-public-maintain @self whiffed @self (whiff_ttl_cycles))))
  (cond
    (case (< ?u ?p) hit)
    (case (< ?u (+ ?p 0.30)) graze)
    (else miss)))

; (inflict-pain ?victim ?amount): a blow's hurt adds to what the victim already feels,
; capped at agony.
(define-func /inline inflict-pain (?victim ?amount)
  (set-attr ?victim pain (min 1.0 (+ (attr ?victim pain) ?amount))))

; (yield-evidence ?target ?site ?blemish) - the forensic trace a blow leaves on the body.
; ?site is the body-part kind struck; ?blemish a leaf of the blemish taxonomy (Objects.mon:
; wound / stain / mark). Written to the struck part's `blemishes` attr, which is /obs +
; auto-percept, so anyone who looks at the body reads it - that is the whole evidence
; channel. Every blow leaves its own mark, so a part struck twice carries the leaf twice; a
; body with no such part is a no-op.
(define-func /inline yield-evidence (?ye-target ?ye-site ?ye-blemish)
  (for-each ?ye-part (spatial ?ye-target parts ?ye-site /env) [/limit 1]
    (add-attr-item ?ye-part blemishes ?ye-blemish)))

; (kill-blow ?foe ?method): the fatal physics - the crime row (goal kill, task the
; specific verb), the objective violent death-cause on the corpse, then (die) (NO
; telepathy; witnesses learn via observation, absentees via the learn_of_death keystone).
; ?method is the striking verb literal.
(define-func kill-blow (?foe ?method)
  (record-crime @self ?foe ?method kill @u @u)
  (set-attr ?foe death-cause [k death-cause violence])
  (die ?foe))
