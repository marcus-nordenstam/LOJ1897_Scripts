; ----------------------------------------------------------------------------
; Apprenticeship (Phase 7). A youth of 12-16 with no employment is taken on as
; a trainee at some org under a master; after several years as a trainee the
; apprenticeship completes and the rank rises to apprentice.
;
; Employment model: a `job` is a mental object whose kind is the occupation;
; `level` rides on the job object. hire / promote (hsim_org_lifecycle) own
; that object - these events only cast the parties and call the verbs.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event apprenticeship_start
  (nl         "?youth is apprenticed")
  (kind       _apprenticeship)
  (schedule   (annually september))
  (band      morning)
  (rng-stream apprenticeship)

  (roles
    ;; ?youth is enumerated and per-youth chance-gated; ?articles is then
    ;; sampled - any org will take an apprentice. The youth's own derived
    ;; situations are usually un-memoised at age 12-16 (derive_prototypes
    ;; runs annually for >=15-year-olds only), so masters cannot yet read
    ;; the apprentice's character directly - they look at lineage instead.
    ;; The breeding dimension is the lineage anchor mx_make_human seeds at
    ;; birth, so it IS available throughout childhood; a low-breeding youth
    ;; (well below the population mean of 55) is rarely taken on by a master.
    (role ?youth (template any_human)
                 (>= (years-old ?self) 12)
                 (<= (years-old ?self) 16)
                 (not (believes ?self {@self employer ?}))
                 (not (believes ?self {@self spouse ?}))
                 ;; A youth still in school (PR-education) is not on the labour
                 ;; market - the working-class on-ramp is for those who left after
                 ;; primary (or never enrolled), not secondary pupils.
                 (not (believes ?self {@self study ?}))
                 (chance (* 0.15 (+ 0.5 (situation ?self breeding)))))
    ;; A master only takes on a youth of sound family. The master comes from
    ;; the articles' founder slot, so the respectability test sits on the
    ;; articles role - resolved by the (let ?master ...) below.
    ;; A household is an org but NOT a trade: no master, no apprenticeship.
    (role ?articles (template org_articles)
                    (not (org-kind-is-a ?self household))
                    (not (= (situation (org-founder ?self) repute) scandalous))))

  ;; Live exclusivity re-check (see employment.hs): the youth's "unemployed"
  ;; filter is alpha-indexed, so within one tick several masters sample the same
  ;; youth before the first apprenticeship commits. We re-check via (job-level
  ;; ...) - a computed op reads live, unlike a belief-pattern (which routes
  ;; through the stale alpha-discriminator). (hire ... :level trainee) sets it
  ;; live, so once apprenticed this tick the youth reads trainee + backtracks.
  (when (not (= (job-level ?youth) trainee)))

  ;; ?master is the org's founder, read from the articles document.
  (let ((?master (org-founder ?articles)))
    (effects
      (hire :articles ?articles :worker ?youth :role clerk :level trainee)
      (begin-belief ?youth master ?master)
      (log _apprenticeship ?youth))))

(hsim-event apprenticeship_completion
  (nl         "?apprentice completes their apprenticeship")
  (kind       _apprenticeship)
  (schedule   (annually september))
  (band      morning)
  (rng-stream apprenticeship)

  (roles
    ;; A trainee who has held the trainee rank at least three years; the
    ;; chance spreads completion over the following years.
    (role ?apprentice (template any_human)
                      (= (job-level ?self) trainee)
                      (>= (job-tenure ?self) 3)
                      (chance 0.4)))

  ;; Recover the master so the master bond can be ended on completion.
  (let ((?master (belief-target ?apprentice master)))
    (effects
      (promote     :worker ?apprentice)
      (end-belief  ?apprentice master ?master)
      (log _apprenticeship ?apprentice))))
