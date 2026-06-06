; ----------------------------------------------------------------------------
; bonded_incident_insult (PR-A-7, 2026-05-28, v2 multiplicative).
;
; First organic insult anchor source. Replaces test_seed_insult's chance-
; primary scaffold once the bonded / public incident family fills out
; (PR-A-10 retires the _test_seed/ directory).
;
; The plan's outcome row:
;   insult | low politeness x narcissism
;          | stress x intoxication x (1 + prestige-gap-either-way)
;          | LIFE_AIM_ALIGN -respectability, -piety
;
; Gating shape (multiplicative-chance, matching the canonical hsim
; pattern from get_drunk.hse): the actor-side `(chance ...)` reads
; the trait product (1 - politeness) x narcissism. A modal NPC at
; (politeness 0.5, narcissism 0.5) hits the base rate x 0.25; a
; sharp-tongued narcissist (politeness 0.3, narcissism 0.7) fires
; 2x as often; a saintly NPC barely fires at all. Substrate-correct
; gradient with no extreme-conjunction cliff (the V1 boolean form
; required politeness < 0.4 AND narcissism > 0.5 simultaneously,
; which excluded most of the population by construction).
;
; Victim-side: personally-knows for the bonded prerequisite + the
; per-pair 90-day cooldown so the same actor doesn't carpet-bomb the
; same victim monthly. The base chance dilutes by victim-population
; scale, then is biased by the actor's durable relational stance toward
; the candidate (relational_stance_plan.md Phase 5): the disliked and
; despised are preferentially targeted, while a neutral acquaintance can
; still be hit (the displaced-anger path - dislike is never required).
;
; The structural amplifiers from the plan's row (stress, intoxication,
; prestige-gap-either-way) and the actor-side emotion-spillover term
; (displaced anger scaled by current anger load) are V3 work.
;
; Schedule: monthly.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event bonded_incident_insult
  (nl       "?actor insults ?victim")
  (kind     _bonded_incident_insult)
  (schedule (monthly))
  (rng-stream incidents)

  (roles
    (role ?actor  (template any_human)
                  (chance (* 0.06
                             (- 1.0 (attr ?actor politeness))
                             (attr ?actor narcissism))))
    (role ?victim (template any_human)
                  (not (= ?victim ?actor))
                  (personally-knows ?actor ?victim)
                  (not (has-recent-incident-marker ?actor ?victim))
                  ; Stance-weighted victim selection (relational_stance_plan.md
                  ; Phase 5). The pool is uniformly sampled, so raising a
                  ; candidate's pool-membership chance raises its odds of being
                  ; the victim. Floor 0.10 is the displaced-anger path: any
                  ; acquaintance can still be hit at the old baseline rate, so we
                  ; never hard-require dislike. Negative warmth (dislike/detest)
                  ; and negative esteem (disdain/despise) add on top - mild +0.15,
                  ; strong +0.30 - so the disliked are preferentially targeted and
                  ; the despised most of all. believes folds to 0/1, so the sums
                  ; are graded counts. Static max = 0.10 + 0.15*2 + 0.30*2 = 1.0,
                  ; which keeps chance's pre-roll early-out (no per-candidate
                  ; fallback warning).
                  (chance (+ 0.10
                             (* 0.15 (+ (believes ?actor {@self dislike ?victim})
                                        (believes ?actor {@self disdain ?victim})))
                             (* 0.30 (+ (believes ?actor {@self detest  ?victim})
                                        (believes ?actor {@self despise ?victim})))))))

  (effects
    (incident-anchor ?actor insult ?victim)
    (log _bonded_incident_insult ?actor)))
