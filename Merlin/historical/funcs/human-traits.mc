; ----------------------------------------------------------------------------
; human-traits.mc - the genetic layer every human is minted with, shared by the
; three ways a human comes into being: a FOUNDER (make-human, parentless), an
; IMMIGRANT (make-human again, parentless for now) and a NEWBORN (the GIVE-BIRTH
; action, two parents).
;
; The ONLY thing that differs between them is the value of one trait: a
; parentless human samples the population distribution, a child blends its
; parents. That difference lives in (trait-value ..) / (inherit-trait ..) and
; nowhere else, so the table walk, the accentuation pass and the seeding order
; are written once.
;
; An unsubstantial ?mother / ?father means parentless - both parents are read
; together, since a half-known lineage is not a lineage.
; ----------------------------------------------------------------------------

(include "../macros/tunables.mc")

; One CONTINUOUS genetic trait (the Big-Five aspects, the dark tetrad,
; attractiveness, the physicals). Parentless: N(mean, sigma) about the
; sex-conditioned population centre. With parents: the mid-parent blend plus a
; pull toward the child's OWN sex-mean, so a daughter of a strong father is
; somewhat strong but still below the male centre. The remaining weight on the
; mean is what keeps population SD near sigma instead of collapsing generation
; over generation.
(define-func trait-value (?trait ?mean ?sigma ?mother ?father)
  (and (substantial ?mother) (substantial ?father)): ?has-parents
  (if ?has-parents
    (then
      (clamp (+ (* (trait_heritability) (attr ?mother ?trait))
                (* (trait_heritability) (attr ?father ?trait))
                (* (- 1 (* 2 (trait_heritability))) ?mean)
                (sample-gaussian 0 ?sigma))
             0 1))
    (else (clamp (sample-gaussian ?mean ?sigma) 0 1))))

; One SINGULAR kind-typed trait (appearance, girth, height, hair, eyes). A child
; takes its mother's, its father's, or a fresh draw, at even odds; a parentless
; human always takes the draw. ?sampled is the caller's draw from that trait's
; own distribution table - the tables differ per trait, so the draw cannot be
; made here.
(define-func inherit-trait (?trait ?sampled ?mother ?father)
  (and (substantial ?mother) (substantial ?father)): ?has-parents
  (if ?has-parents
    (then
      (random-int 0 2): ?pick
      (if (= ?pick 0)
        (then (attr ?mother ?trait))
        (else (if (= ?pick 1) (then (attr ?father ?trait)) (else ?sampled)))))
    (else ?sampled)))

; The sex-conditioned population centre for one continuous trait, off its row.
; Most traits are not dimorphic and carry the same figure in both columns.
(define-func sex-trait-mean (?gender ?mean-male ?mean-female)
  (if (= ?gender [k male]) (then ?mean-male) (else ?mean-female)))

; Write every continuous genetic trait onto ?h.
(define-func seed-continuous-traits (?h ?gender ?mother ?father)
  (for-each-row continuous_traits
      [/trait ?t] [/mean-male ?mm] [/mean-female ?mf] [/sigma ?sg]
    (sex-trait-mean ?gender ?mm ?mf): ?mean
    (set-attr ?h ?t (trait-value ?t ?mean ?sg ?mother ?father))))

; Give every human a recognisable profile: one clearly above-normal and one
; clearly below-normal trait. A normal distribution keeps ~68% of a population
; within 1 SD, and the mid-parent blend holds later generations there, so
; without this almost nobody stands out. It AMPLIFIES whichever extremes the
; sampling already produced rather than imposing new ones, so an inherited
; tendency survives the regression toward the mean; the two traits pushed differ
; per human, so population means stay put. The jitter spreads the forced
; standouts instead of piling them on the threshold.
(define-func accentuate-traits (?h ?gender)
  (bind @nothing ?hi-trait)
  (bind 0 ?hi-mean)
  (bind -2 ?hi-dev)
  (bind @nothing ?lo-trait)
  (bind 0 ?lo-mean)
  (bind 2 ?lo-dev)
  (for-each-row continuous_traits
      [/trait ?t] [/mean-male ?mm] [/mean-female ?mf]
    (sex-trait-mean ?gender ?mm ?mf): ?mean
    (- (attr ?h ?t) ?mean): ?dev
    (if (> ?dev ?hi-dev)
      (then (bind ?t ?hi-trait) (bind ?mean ?hi-mean) (bind ?dev ?hi-dev)))
    (if (< ?dev ?lo-dev)
      (then (bind ?t ?lo-trait) (bind ?mean ?lo-mean) (bind ?dev ?lo-dev))))
  (if (and (substantial ?hi-trait) (< ?hi-dev (standout_delta)))
    (then
      (set-attr ?h ?hi-trait
        (clamp (+ ?hi-mean (standout_delta) (* (rng-unit) (standout_jitter))) 0 1))))
  ; The low pick is only distinct from the high pick when the table has two rows
  ; to choose between; with one it would undo the push just made.
  (if (and (substantial ?lo-trait)
           (not (= ?lo-trait ?hi-trait))
           (> ?lo-dev (- 0 (standout_delta))))
    (then
      (set-attr ?h ?lo-trait
        (clamp (- ?lo-mean (standout_delta) (* (rng-unit) (standout_jitter))) 0 1)))))

; The permanent lineage anchor, seeded ONCE from the origin class. class-situation
; is later re-derived from breeding + prestige + wealth, so breeding must not
; itself read class-situation - seeding it from the raw origin class keeps that
; derivation acyclic.
(define-func breeding-for-class (?class)
  (if (is-a ?class [k class-situation upper])
    (then (breeding_upper))
    (else
      (if (is-a ?class [k class-situation middle])
        (then (breeding_middle))
        (else (breeding_lower))))))

; Write every singular kind-typed trait onto ?h. Each is drawn from its own
; distribution table; with parents the draw is one of three even chances against
; the parents' own values.
(define-func seed-singular-traits (?h ?mother ?father)
  (set-attr ?h appearance
    (inherit-trait appearance (table-sample-weighted appearance_dist value weight)
                   ?mother ?father))
  (set-attr ?h girth
    (inherit-trait girth (table-sample-weighted girth_dist value weight)
                   ?mother ?father))
  (set-attr ?h height
    (inherit-trait height (table-sample-weighted height_dist value weight)
                   ?mother ?father))
  (set-attr ?h hair-color
    (inherit-trait hair-color (table-sample-weighted hair_color_dist value weight)
                   ?mother ?father))
  (set-attr ?h eye-color
    (inherit-trait eye-color (table-sample-weighted eye_color_dist value weight)
                   ?mother ?father)))

; THE genetic layer: everything a human inherits or is dealt at the moment it
; exists. The one call every creation path makes - founder and immigrant with
; unsubstantial parents, newborn with both.
(define-func seed-human-genetics (?h ?gender ?mother ?father)
  (seed-singular-traits ?h ?mother ?father)
  (seed-continuous-traits ?h ?gender ?mother ?father)
  (accentuate-traits ?h ?gender))
