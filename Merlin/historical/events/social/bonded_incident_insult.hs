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
; the candidate: the disliked and
; despised are preferentially targeted, while a neutral acquaintance can
; still be hit (the displaced-anger path - dislike is never required).
;
; The actor-side emotion-spillover term (displaced anger scaled by the current
; anger load) is wired into the actor chance below. The remaining
; structural amplifiers (stress, intoxication,
; prestige-gap-either-way) are still future work (see Docs/future_work.md).
;
; Schedule: monthly.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event bonded_incident_insult
  (nl       "?actor insults ?victim")
  (kind     _bonded_incident_insult)
  (schedule (monthly))
  (band      evening)
  (rng-stream incidents)

  (roles
    (role ?actor  (template any_human)
                  ; Two additive impulse sources:
                  ;  - the dispositional base: low politeness x narcissism;
                  ;  - displaced anger: a high current ANGER load (from ANY
                  ;    source, summed across foci) raises the urge to lash out,
                  ;    discharged on whatever the victim pool offers - the 0.10
                  ;    displacement floor on ?victim lets an innocent acquaintance
                  ;    be hit, so the anger need not be AT the victim.
                  ; emotion-load is unbounded, so this chance takes the
                  ; per-candidate slow path (one benign load-time warning); the
                  ; actor role is enumerated per candidate regardless, so there is
                  ; no added cost.
                  (chance (+ (* 0.06
                                (- 1.0 (attr ?actor politeness))
                                (attr ?actor narcissism))
                             (* 0.08 (emotion-load ?actor anger)))))
    (role ?victim (template any_human)
                  (not (= ?victim ?actor))
                  (personally-knows ?actor ?victim)
                  (not (has-recent-incident-marker ?actor ?victim))
                  ; Stance-weighted victim selection.
                  ; The pool is uniformly sampled, so raising a
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
