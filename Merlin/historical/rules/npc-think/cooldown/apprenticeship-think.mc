; ----------------------------------------------------------------------------
; Apprenticeship (Phase 7). A youth of 12-16 with no employment is taken on as
; a trainee at some org under a master; after several years as a trainee the
; apprenticeship completes and the rank rises to apprentice.
;
; Employment model: a `job` is a mental object whose kind is the occupation;
; `level` rides on the job object. hire / promote (hsim_org_lifecycle) own
; that object - these rules only cast the parties and call the verbs.
;
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think apprenticeship_start
  (cooldown 1 m)
  (rng-stream apprenticeship)

  ;; ?youth is enumerated and per-youth chance-gated; ?articles is then
  ;; sampled - any org will take an apprentice. The youth's own derived
  ;; situations are usually un-memoised at age 12-16 (derive_prototypes
  ;; runs annually for >=15-year-olds only), so masters cannot yet read
  ;; the apprentice's character directly - they look at lineage instead.
  ;; The breeding dimension is the lineage anchor mx_make_human seeds at
  ;; birth, so it IS available throughout childhood; a low-breeding youth
  ;; (well below the population mean of 55) is rarely taken on by a master -
  ;; that breeding-weighted (chance) and the 12-16 age window are non-belief
  ;; @self reads, so they gate the fire in (when), not role selection.
  ;; SELF-POV (telepathy purge CAT-2): the youth is the sole deliberator,
  ;; reading his OWN employment / marital / schooling state.
  (role @self {@self breeding ?breeding}
              -{@self job.salary ?}
              -{@self spouse ?}
              ;; A youth still in school (PR-education) is not on the labour
              ;; market - the working-class on-ramp is for those who left after
              ;; primary (or never enrolled), not secondary pupils.
              -{@self study ?})
  ;; A KNOWN org (the youth learned it at new_job_orientation), not a household:
  ;; a household is an org but NOT a trade - no master, no apprenticeship. Belief-
  ;; pure + cached. The master gate (the org's founder, whom the youth avoids if
  ;; KNOWN to be scandalous - permissive on the unknown) is a residual filter on
  ;; ?master, produced off {?org founder ?master} and re-checked in the role.
  (role ?org {?org isa [k org]}
             -{?org isa [k org household]}
             {?org founder ?master}
             -{?master repute [k scandalous]}
             {?org record ?org_record})

  ;; Live exclusivity re-check (see employment.hs): the youth's "unemployed"
  ;; filter is alpha-indexed, so within one tick several masters sample the same
  ;; youth before the first apprenticeship commits. We re-check via a live
  ;; (any ...) two-hop read of the youth's own job then level - reading it live,
  ;; unlike a belief-pattern (which routes
  ;; through the stale alpha-discriminator). (hire ... /level trainee) sets it
  ;; live, so once apprenticed this tick the youth reads trainee + backtracks.
  ;; Role-belief-purity: the per-youth (chance) gate (low-breeding youths, below
  ;; the population mean of 55, are rarely taken on) and the 12-16 age window are
  ;; non-belief @self reads, so they moved here from the @self role; (chance) leads
  ;; the (and ...) to short-circuit cheaply.
  (when (and (chance (* 0.0125 (+ 0.5 ?breeding)))
             (!= (any {(any {@self job ?}).target level ?}).target [k trainee])
             (>= (years-old @self) 12)
             (<= (years-old @self) 16)))

  ;; The youth chooses a trade and proposes the seek-indenture task (npc-tasks/
  ;; seek-indenture-task.hs), which sends him to the master's premises and enrols him
  ;; there. maintain-proposal keeps ONE standing search, retargeted each fire as the
  ;; roulette lands on a different master (a per-target begin would stack a distinct
  ;; proposal per org's articles and overflow the attention set).
  ;; Focus = the org's articles, recovered from @self's {?org record ?art} belief.
  ;; MAINTENANCE: the decision OWNS the seek-indenture proposal end to end. While the
  ;; youth is unemployed (role @self (none {@self job.salary ?})) and not yet a trainee
  ;; (the (when) trainee-rank gate), the proposal stands; the moment seek-indenture's
  ;; ENROL files his clerk row and hire-beliefs mints {@self job ...}, both gates fall
  ;; and maintain-proposal withdraws. The task never ends the motivating proposal.
  (utility errand)
  (effects (maintain-proposal {@self seek-indenture ?org_record})))

(npc-think apprenticeship_completion
  (cooldown 1 m)
  (rng-stream apprenticeship)

  ;; The trainee is the sole deliberator (@self). The trainee-rank read / job-tenure
  ;; (.start macro) / chance gate the fire in (when), not role selection.
  (role @self )

  ;; A trainee who has held the trainee rank at least three years; the chance
  ;; spreads completion over the following years (0.033/mo ~= the old 0.4/yr).
  (when (and (= (any {(any {@self job ?}).target level ?}).target [k trainee])
             (>= (job-tenure @self) 3)
             (chance 0.033)))

  (effects
    ;; Advance his own rank one rung (trainee -> apprentice; the (when) gates this
    ;; lane to trainees). His own job belief only - the master's standing assessment
    ;; is the master's to re-accrue, never edited from here.
    (any {@self job ?job})
    (end-belief {?job level [k trainee]})
    (begin-belief {?job level [k apprentice]})
    (for-each ?mb-rel (every {@self master ?})
        (end-belief ?mb-rel))
    ))
