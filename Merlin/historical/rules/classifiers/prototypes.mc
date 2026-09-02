; ----------------------------------------------------------------------------
; Prototypes (Shape B toggles). Each is a (mint-band {@self prototype}
; <bool> [k prototype <proto>] 0.5): a single band at 0.5 IS a toggle (bool >= 0.5
; begins the kind, < 0.5 ends it), and mint-band's held-scan only matches the ONE
; declared kind, so a toggle never disturbs the other (non-@excl) prototype beliefs.
; Booleans compose as products of (believes)/(>=)/(<=) 0-or-1 terms; OR =
; (clamp (+ ...) 0 1). Gated on a PERSISTENT input band (plus the held prototype
; itself, for inputs like craving that can end) so the toggle can flip OFF when the
; condition lapses.
; ----------------------------------------------------------------------------

; drunkard: a standing craving for drink IS the dependency.
(npc-think classify_drunkard
  ; The drunkard toggle mints when a craving is present and REMOVES when it is forgotten
  ; (rehabilitation). The gate's prototype disjunct keeps the rule eligible across the
  ; removing fire.
  (rng-stream behaviour)
  (role @self (or {@self craving ?}
                  {@self prototype [k prototype drunkard]}))
  (effects
    (mint-band {@self prototype} (prob {@self craving ?})
      [k prototype drunkard] 0.5)))

; nouveau-riche: high wealth (>= 0.60) carried by low breeding (<= 0.35).
(npc-think classify_nouveau_riche
  ; wealth re-derives annually; breeding is birth-seeded (an inert input, kept to document it).
  ; The toggle drops if wealth is retracted.
  (rng-stream behaviour)
  (role @self {@self wealth ?wealth, breeding ?breeding})
  (effects
    (mint-band {@self prototype}
      (* (>= ?wealth 0.60)
         (<= ?breeding 0.35))
      [k prototype nouveau-riche] 0.5)))

; self-made-man: rising trajectory + arrived class + low breeding + reputable.
(npc-think classify_self_made_man
  ; Toggle over the situation bands + repute (a Tier-2 sibling this reads);
  ; breeding is birth-seeded (inert). It drops when any input band toggles off.
  (rng-stream behaviour)
  (role @self {@self class-situation ?, breeding ?breeding})
  (effects
    (mint-band {@self prototype}
      (* (prob {@self social-trajectory [k social-trajectory rising]})
         (clamp (+ (prob {@self class-situation [k class-situation middle]})
                   (prob {@self class-situation [k class-situation upper]})) 0 1)
         (<= ?breeding 0.40)
         (clamp (+ (prob {@self repute [k repute exemplary]})
                   (prob {@self repute [k repute respectable]})) 0 1))
      [k prototype self-made-man] 0.5)))

; deserving-poor: poor/destitute + reputable.
(npc-think classify_deserving_poor
  (rng-stream behaviour)
  (role @self {@self economic-situation ?})
  (effects
    (mint-band {@self prototype}
      (* (clamp (+ (prob {@self economic-situation [k economic-situation poor]})
                   (prob {@self economic-situation [k economic-situation destitute]})) 0 1)
         (clamp (+ (prob {@self repute [k repute exemplary]})
                   (prob {@self repute [k repute respectable]})) 0 1))
      [k prototype deserving-poor] 0.5)))

; undeserving-poor: poor/destitute + disreputable.
(npc-think classify_undeserving_poor
  (rng-stream behaviour)
  (role @self {@self economic-situation ?})
  (effects
    (mint-band {@self prototype}
      (* (clamp (+ (prob {@self economic-situation [k economic-situation poor]})
                   (prob {@self economic-situation [k economic-situation destitute]})) 0 1)
         (clamp (+ (prob {@self repute [k repute disreputable]})
                   (prob {@self repute [k repute scandalous]})) 0 1))
      [k prototype undeserving-poor] 0.5)))

; go-between (the underworld fixer) - NOT-reputable (neither exemplary nor
; respectable) + lower/middle class + the externalizing temperament to broker
; violence (the corrupt publican / fence / flash sporting-man). NB "disinhibition"
; here is the externalizing trait fold (low industriousness + low politeness +
; high volatility), NOT the (disinhibition) = 1 - inhibition macro.
;
; TODO - this is SELF-knowledge only, and nothing reads it yet.
; The old C++ hireling census walked every mind to build a global "fixer pool";
; that was a director read and is purged. A fixer is worth nothing until another
; mind can come to believe {?other prototype go-between} on its own evidence, so
; the work is:
;   (a) a per-observer twin, classify_others_go_between, on the
;       classify_others_repute template in repute.mc - (role ?other ..) +
;       (mint-band-about {?other prototype} ..) folding only what @self has
;       personally witnessed or been told about ?other;
;   (b) an "ask the fixer" rung in hire-assassin-task.mc, since the whole POINT of
;       a go-between is that you need not know a killer yourself - you need to know
;       someone who does. That rung is how an employer ACQUIRES the name.
(npc-think classify_go_between
  (rng-stream behaviour)
  (role @self {@self repute ?, class-situation ?})
  (effects
    (mint-band {@self prototype}
      (* (* (- 1 (prob {@self repute [k repute exemplary]}))
            (- 1 (prob {@self repute [k repute respectable]})))
         (clamp (+ (prob {@self class-situation [k class-situation lower]})
                   (prob {@self class-situation [k class-situation middle]})) 0 1)
         (>= (/ (+ (- 1 (attr @self industriousness))
                   (- 1 (attr @self politeness))
                   (attr @self volatility)) 3)
             0.50))
      [k prototype go-between] 0.5)))

; for-hire: CAPABILITY (a lethal skill OR raw brute strength) AND REASON (economic
; desperation OR a callous, disinhibited bad-seed). Split into a skilled path (role
; binds a martial / garrotting skill) and a MUTUALLY-EXCLUSIVE brute path (role
; excludes such a skill), so the two never clobber the shared for-hire toggle and a
; skill-loss hands the subject cleanly to the brute path. "disinhibition" is the
; externalizing fold, as in classify_go_between.
;
; The skill-level reads below are shape-correct: the action pipeline emits
; {@self skill-level [k <domain>] [k <rung>]}, a DOMAIN-kind target, which is what
; these clauses match. They stay quiet only while no act accruing martial /
; garrotting skill is being performed.
;
; TODO - same gap as classify_go_between: this is SELF-knowledge and nothing reads
; it. An employer cannot see another mind's willingness to kill for money. Needs a
; per-observer classify_others_for_hire (the classify_others_repute template in
; repute.mc) fed by legal evidence only - witnessed violence, reputation, gossip,
; or the solicitation itself, since asking someone and hearing their answer IS how
; you learn it. Then hire-assassin-task.mc prefers a believed hireling and proposes
; ACQUIRING that belief when it holds none.

; skilled path: a martial or garrotting skill IS the capability; mint on reason.
(npc-think classify_for_hire_skilled
  (rng-stream behaviour)
  (role @self {@self economic-situation ?}
              (or {@self skill-level [k martial]}
                  {@self skill-level [k garrotting]}))
  (effects
    (mint-band {@self prototype}
      ; REASON: economic desperation OR the callous + disinhibited bad seed.
      (clamp (+ (clamp (+ (prob {@self economic-situation [k economic-situation poor]})
                          (prob {@self economic-situation [k economic-situation destitute]})) 0 1)
                (* (<= (attr @self compassion) 0.40)
                   (>= (/ (+ (- 1 (attr @self industriousness))
                             (- 1 (attr @self politeness))
                             (attr @self volatility)) 3)
                       0.55))) 0 1)
      [k prototype for-hire] 0.5)))

; brute path: the lower-class strong man with NO lethal skill (footpad / cosh thug).
(npc-think classify_for_hire_brute
  (rng-stream behaviour)
  (role @self {@self economic-situation ?, class-situation ?}
              -{@self skill-level [k martial]}
              -{@self skill-level [k garrotting]})
  (effects
    (mint-band {@self prototype}
      (* (>= (attr @self strength) 0.65)
         (prob {@self class-situation [k class-situation lower]})
         (clamp (+ (clamp (+ (prob {@self economic-situation [k economic-situation poor]})
                             (prob {@self economic-situation [k economic-situation destitute]})) 0 1)
                   (* (<= (attr @self compassion) 0.40)
                      (>= (/ (+ (- 1 (attr @self industriousness))
                                (- 1 (attr @self politeness))
                                (attr @self volatility)) 3)
                          0.55))) 0 1))
      [k prototype for-hire] 0.5)))
