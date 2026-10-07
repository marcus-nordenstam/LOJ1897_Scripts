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

; The continuous genetic traits (Big-Five aspects + dark tetrad + attractiveness +
; physical). mean is sex-conditioned (strength / endurance dimorphic; the rest 0.5);
; every trait samples N(mean, sigma) clamped 0..1.
(define-table continuous_traits
  (fields trait mean-male mean-female sigma)
  (record openness         0.5  0.5  0.15)
  (record intellect        0.5  0.5  0.15)
  (record industriousness  0.5  0.5  0.15)
  (record orderliness      0.5  0.5  0.15)
  (record enthusiasm       0.5  0.5  0.15)
  (record assertiveness    0.5  0.5  0.15)
  (record compassion       0.5  0.5  0.15)
  (record politeness       0.5  0.5  0.15)
  (record volatility       0.5  0.5  0.15)
  (record withdrawal       0.5  0.5  0.15)
  (record narcissism       0.5  0.5  0.15)
  (record machiavellianism 0.5  0.5  0.15)
  (record psychopathy      0.5  0.5  0.15)
  (record sadism           0.5  0.5  0.15)
  (record attractiveness   0.5  0.5  0.15)
  (record strength         0.6  0.4  0.15)
  (record dexterity        0.5  0.5  0.15)
  (record agility          0.5  0.5  0.15)
  (record endurance        0.55 0.45 0.15))

(define-table eye_color_dist
  (fields value weight)
  (record [k brown] 4)
  (record [k blue]  4)
  (record [k green] 2)
  (record [k hazel] 2)
  (record [k grey]  1))

(define-table hair_color_dist
  (fields value weight)
  (record [k brown]  5)
  (record [k black]  3)
  (record [k blonde] 2)
  (record [k auburn] 1)
  (record [k red]    1))

(define-table height_dist
  (fields value weight)
  (record [k short]  1)
  (record [k medium-height] 4)
  (record [k tall]   1))

(define-table girth_dist
  (fields value weight)
  (record [k thin]   1)
  (record [k medium-girth] 4)
  (record [k fat]    2))

; The school a hand is taught in follows the schooling a class buys.
(define-table handwriting_upper_dist
  (fields value weight)
  (record [k copperplate] 4)
  (record [k spencerian]  2)
  (record [k italic]      2))
(define-table handwriting_middle_dist
  (fields value weight)
  (record [k commercial] 4)
  (record [k round-hand] 2)
  (record [k copperplate] 1))
(define-table handwriting_lower_dist
  (fields value weight)
  (record [k schoolroom] 3)
  (record [k scrawl]     3))
(define-table handwriting_schools
  (fields school)
  (record [k copperplate])
  (record [k spencerian])
  (record [k round-hand])
  (record [k commercial])
  (record [k italic])
  (record [k schoolroom])
  (record [k scrawl]))
; What a school's hands range over: slant in degrees, weight as stroke thickening, letter and
; line spacing in points added, regularity 0 (shaky) to 1 (even). A hand is dealt from the
; middle of each range, bell-shaped, and never outside it.
(define-table handwriting_aspect_bounds
  (fields school slant-lo slant-hi weight-lo weight-hi
          letter-lo letter-hi line-lo line-hi regularity-lo regularity-hi)
  (record [k copperplate]  15.0 30.0 -0.05 0.10 -0.5 1.0  0.0 2.0 0.80 0.95)
  (record [k spencerian]   20.0 40.0 -0.10 0.05  0.0 1.5  0.0 3.0 0.75 0.95)
  (record [k round-hand]    5.0 20.0  0.00 0.15 -0.5 1.0  0.0 2.0 0.80 0.95)
  (record [k commercial]   10.0 35.0  0.00 0.20 -1.0 2.0 -1.0 3.0 0.55 0.80)
  (record [k italic]        0.0 10.0 -0.05 0.10 -0.5 1.5  0.0 3.0 0.70 0.90)
  (record [k schoolroom]   -5.0 15.0  0.05 0.25  0.0 2.0  0.0 4.0 0.45 0.70)
  (record [k scrawl]      -15.0 45.0  0.00 0.30 -1.0 4.0 -2.0 6.0 0.15 0.45))
(define-table appearance_dist
  (fields value weight)
  (record [k ugly]          1)
  (record [k plain-looking] 4)
  (record [k beautiful]     2))

(include "../macros/tunables.mc")
(include "../macros/physiology-macros.mc")

; One CONTINUOUS genetic trait (the Big-Five aspects, the dark tetrad,
; attractiveness, the physicals). Parentless: N(mean, sigma) about the
; sex-conditioned population centre. With parents: the mid-parent blend plus a
; pull toward the child's OWN sex-mean, so a daughter of a strong father is
; somewhat strong but still below the male centre. The remaining weight on the
; mean is what keeps population SD near sigma instead of collapsing generation
; over generation.
(define-func trait-value (?trait ?mean ?sigma ?mother ?father)
  (tolerate (and (substantial ?mother) (substantial ?father))): ?has-parents
  (if ?has-parents
    (then
      (clamp (+ (* (trait_heritability) (attr ?mother ?trait))
                (* (trait_heritability) (attr ?father ?trait))
                (* (- 1.0 (* 2.0 (trait_heritability))) ?mean)
                (sample-gaussian 0.0 ?sigma))
             0.0 1.0))
    (else (clamp (sample-gaussian ?mean ?sigma) 0.0 1.0))))

; One SINGULAR kind-typed trait (appearance, girth, height, hair, eyes). A child
; takes its mother's, its father's, or a fresh draw, at even odds; a parentless
; human always takes the draw. ?sampled is the caller's draw from that trait's
; own distribution table - the tables differ per trait, so the draw cannot be
; made here.
(define-func inherit-trait (?trait ?sampled ?mother ?father)
  (tolerate (and (substantial ?mother) (substantial ?father))): ?has-parents
  (if ?has-parents
    (then
      (random-int 0 2): ?pick
      (switch ?pick
        (on 0 (attr ?mother ?trait))
        (on 1 (attr ?father ?trait))
        (else ?sampled)))
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
  (bind 0.0 ?hi-mean)
  (bind -2.0 ?hi-dev)
  (bind @nothing ?lo-trait)
  (bind 0.0 ?lo-mean)
  (bind 2.0 ?lo-dev)
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
        (clamp (+ ?hi-mean (standout_delta) (* (rng-unit) (standout_jitter))) 0.0 1.0))))
  ; The low pick is only distinct from the high pick when the table has two rows
  ; to choose between; with one it would undo the push just made.
  (if (and (substantial ?lo-trait)
           (not (= ?lo-trait ?hi-trait))
           (> ?lo-dev (- 0.0 (standout_delta))))
    (then
      (set-attr ?h ?lo-trait
        (clamp (- ?lo-mean (standout_delta) (* (rng-unit) (standout_jitter))) 0.0 1.0)))))

; The permanent lineage anchor, seeded ONCE from the origin class. class-situation
; is later re-derived from breeding + prestige + wealth, so breeding must not
; itself read class-situation - seeding it from the raw origin class keeps that
; derivation acyclic.
(define-func breeding-for-class (?class)
  (switch (kind ?class)
    (on [k upper]  (breeding_upper))
    (on [k middle] (breeding_middle))
    (else (breeding_lower))))

; The school ?h is taught to write in: a child learns its mother's, anyone else the one
; its class buys.
(define-func handwriting-school (?class ?mother)
  (bind @nothing ?school)
  (if (substantial ?mother)
    (then
      (for-each-row handwriting_schools [/school ?s]
        (if (is-a (attr ?mother handwriting) ?s) (then (bind ?s ?school) (break)))))
    (else
      (switch (kind ?class)
        (on [k upper]
          (bind (table-sample-weighted handwriting_upper_dist value weight) ?school))
        (on [k middle]
          (bind (table-sample-weighted handwriting_middle_dist value weight) ?school))
        (else
          (bind (table-sample-weighted handwriting_lower_dist value weight) ?school)))))
  ?school)

; One aspect of a hand: a bell-shaped draw about the middle of [?lo ?hi], clamped to it.
(define-func deal-hand-aspect (?lo ?hi)
  (clamp (sample-gaussian (* 0.5 (+ ?lo ?hi)) (* 0.25 (- ?hi ?lo))) ?lo ?hi))

; ?h's own hand: a leaf of its school no other human holds, and the aspects it is written
; with, dealt within the school's bounds.
(define-func seed-handwriting (?h ?class ?mother)
  (handwriting-school ?class ?mother): ?school
  (set-attr ?h handwriting (random-unheld-subkind ?school [k human] handwriting))
  (for-each-row handwriting_aspect_bounds
      [/school ?s] [/slant-lo ?slant-lo] [/slant-hi ?slant-hi]
      [/weight-lo ?weight-lo] [/weight-hi ?weight-hi]
      [/letter-lo ?letter-lo] [/letter-hi ?letter-hi] [/line-lo ?line-lo] [/line-hi ?line-hi]
      [/regularity-lo ?regularity-lo] [/regularity-hi ?regularity-hi]
    (if (is-a ?school ?s)
      (then
        (set-attr ?h hand-slant (deal-hand-aspect ?slant-lo ?slant-hi))
        (set-attr ?h hand-weight (deal-hand-aspect ?weight-lo ?weight-hi))
        (set-attr ?h hand-letter-spacing (deal-hand-aspect ?letter-lo ?letter-hi))
        (set-attr ?h hand-line-spacing (deal-hand-aspect ?line-lo ?line-hi))
        (set-attr ?h hand-regularity (deal-hand-aspect ?regularity-lo ?regularity-hi))
        (break)))))

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
  (accentuate-traits ?h ?gender)
  (set-attr ?h chronotype (clamp (sample-gaussian 0.0 (chronotype_sigma_hours))
                                 (- 0.0 (chronotype_max_hours)) (chronotype_max_hours))))

; The body at rest: the drives run_physiology advances from here.
(define-func seed-human-vitals (?h)
  (set-attr ?h adrenaline 0)
  (set-attr ?h fatigue 0)
  (set-attr ?h sleepiness 0)
  (set-attr ?h hunger 0)
  (set-attr ?h appetite 0)
  (set-attr ?h pain 0))

; An NPC starts sober and unhooked; DRINK and PLAY-GAME move these from here.
(define-func seed-npc-habits (?h)
  (set-attr ?h intoxication 0)
  (set-attr ?h gambling-addiction 0))
