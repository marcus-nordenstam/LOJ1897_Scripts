; ----------------------------------------------------------------------------
; occupations.hs - the job catalog as authored config (a (define-table ...) with
; NAMED records, like businesses / cornerstone_businesses). Loaded from
; historical/tables/ into the .hse catalog; consumed by the (select-row ...)
; hiring match in hire_errand_act.hs - there is NO bespoke C++ parser, struct,
; or catalog (the old hsim_occupations.{h,cc} loader was deleted).
;
; One row per job (a named record: unlisted fields take the (defaults ...) fill):
;   job            - the job kind, [k job <leaf>] (the KEY; matches Concepts.mon).
;   class_floor    - minimum class allowed (HARD hiring gate).
;   business_type  - the org kind that hosts this post, or `none` = generic (a
;                    cook / clerk / maid works anywhere).
;   may_own        - true = a proprietor-grade post. may_own with NO business_type
;                    (landlord / proprietor) is entered by FOUNDING, never hired.
;   req_repute     - HARD: minimum reputation band, or `none`. Trust-sensitive
;                    posts (banking, clerical, the professions) gate on a PROVEN
;                    band - an unappraised repute fails the gate.
;   req_skill + band - HARD: must hold {@self skilled_in <domain>} at >= the band
;                    (novice < trained < expert), or `none`. Education credentials
;                    AND tenure-conferred domain skill are both skilled_in entries,
;                    so this doubles as the EXPERIENCE requirement. ONLY gate
;                    ADVANCED rungs - an ENTRY job must NOT require its own domain
;                    (you learn it on the job), or nobody could be hired into it.
;   pref_trait1/2 + weights - SOFT: preferred personality attrs scoring the match
;                    among the eligible (never block a hire).
;
; THE LADDER (why some jobs carry req_skill and entry jobs do not):
;   clerk (entry, learns accountancy on the job) --tenure--> banker (req
;   accountancy trained). engineer (entry) --tenure--> industrialist (req
;   engineering trained). journalist (entry) --tenure--> editor (req literature
;   trained). University degree --> physician/surgeon (medicine trained),
;   solicitor (law trained). Secondary credential --> teacher/principal.
; Lower-class trades carry NO hard gates - the on-ramp must stay open.
;
; The domain a job CONFERS competence in lives in occupation_domains.hs; the
; working hours live in occupation_shifts.hs.
; ----------------------------------------------------------------------------

(define-table occupations
  (fields job class_floor business_type may_own req_repute req_skill req_skill_band
          pref_trait1 pref_w1 pref_trait2 pref_w2)
  (defaults none none none false none none none none 0 none 0)

  ;; --- Upper-class professions ---
  (record (job [k job banker])
     (class_floor [k middle])
     (business_type [k org bank])
     (may_own true)
     (req_repute [k respectable])
     (req_skill [k accountancy] [k trained])
     (pref_trait1 industriousness 1.0)
     (pref_trait2 politeness 0.6))

  (record (job [k job industrialist])
     (class_floor [k upper])
     (business_type [k org factory])
     (may_own true)
     (req_repute [k respectable])
     (req_skill [k engineering] [k trained])
     (pref_trait1 assertiveness 1.0)
     (pref_trait2 industriousness 0.8))

  ; landlord / proprietor: may_own with NO business_type - founding-only posts,
  ; skipped by the hiring match.
  (record (job [k job landlord])
     (class_floor [k middle])
     (may_own true)
     (req_repute [k respectable])
     (pref_trait1 assertiveness 0.8)
     (pref_trait2 industriousness 0.6))

  (record (job [k job merchant])
     (class_floor [k middle])
     (business_type [k org shipping_agent])
     (may_own true)
     (pref_trait1 assertiveness 1.0)
     (pref_trait2 enthusiasm 0.6))

  (record (job [k job proprietor])
     (class_floor [k middle])
     (may_own true)
     (pref_trait1 assertiveness 0.8)
     (pref_trait2 industriousness 0.8))

  (record (job [k job solicitor])
     (class_floor [k middle])
     (business_type [k org solicitor_firm])
     (may_own true)
     (req_repute [k respectable])
     (req_skill [k law] [k trained])
     (pref_trait1 industriousness 1.0)
     (pref_trait2 openness 0.5))

  (record (job [k job physician])
     (class_floor [k middle])
     (business_type [k org hospital])
     (req_repute [k respectable])
     (req_skill [k medicine] [k trained])
     (pref_trait1 compassion 0.8)
     (pref_trait2 industriousness 0.8))

  (record (job [k job surgeon])
     (class_floor [k middle])
     (business_type [k org hospital])
     (req_repute [k respectable])
     (req_skill [k medicine] [k trained])
     (pref_trait1 industriousness 1.0)
     (pref_trait2 assertiveness 0.5))

  ; apothecary: may_own + business_type, so entered by founding OR hired as a
  ; junior who learns medicine on the counter (no req_skill - the on-ramp).
  (record (job [k job apothecary])
     (class_floor [k middle])
     (business_type [k org apothecary])
     (may_own true)
     (req_repute [k respectable])
     (pref_trait1 industriousness 0.8))

  ; priest: irregular week (Sunday IS the working day) - see occupation_shifts.hs.
  (record (job [k job priest])
     (class_floor [k middle])
     (business_type [k org church])
     (req_repute [k respectable])
     (pref_trait1 politeness 0.8)
     (pref_trait2 compassion 0.8))

  (record (job [k job principal])
     (class_floor [k middle])
     (business_type [k org private_school])
     (req_repute [k respectable])
     (req_skill [k secondary_school_curriculum] [k trained])
     (pref_trait1 politeness 0.8)
     (pref_trait2 industriousness 0.8))

  ; professor: the university don. Confers no domain - a don's competence is the
  ; degree they earned (minted at graduation), not a skill the post confers.
  (record (job [k job professor])
     (class_floor [k upper])
     (business_type [k org university])
     (req_repute [k respectable])
     (pref_trait1 openness 1.0)
     (pref_trait2 industriousness 0.6))

  ;; --- Middle-class professions ---
  ; editor: the senior newspaper post, reached by a journalist who has built the
  ; literature domain on the job.
  (record (job [k job editor])
     (class_floor [k middle])
     (business_type [k org newspaper])
     (may_own true)
     (req_repute [k respectable])
     (req_skill [k literature] [k trained])
     (pref_trait1 openness 0.8)
     (pref_trait2 assertiveness 0.6))

  ; journalist: ENTRY to the literature domain (no req_skill - learns on the job).
  (record (job [k job journalist])
     (class_floor [k middle])
     (business_type [k org newspaper])
     (pref_trait1 openness 1.0)
     (pref_trait2 enthusiasm 0.6))

  (record (job [k job printer])
     (class_floor [k middle])
     (business_type [k org newspaper])
     (pref_trait1 industriousness 0.8))

  (record (job [k job teacher])
     (class_floor [k middle])
     (business_type [k org state_school])
     (req_repute [k respectable])
     (req_skill [k secondary_school_curriculum] [k novice])
     (pref_trait1 politeness 0.8)
     (pref_trait2 compassion 0.6))

  ; engineer: ENTRY to the engineering domain (the senior rung is industrialist,
  ; which requires engineering trained).
  (record (job [k job engineer])
     (class_floor [k middle])
     (pref_trait1 industriousness 1.0)
     (pref_trait2 openness 0.5))

  ; clerk: ENTRY to accountancy (the senior rung is banker, which requires
  ; accountancy trained). Clerical work needs a respectable name.
  (record (job [k job clerk])
     (class_floor [k middle])
     (req_repute [k respectable])
     (pref_trait1 industriousness 1.0)
     (pref_trait2 politeness 0.5))

  (record (job [k job typist])
     (class_floor [k middle])
     (req_repute [k respectable])
     (pref_trait1 industriousness 0.8))

  (record (job [k job house_agent])
     (class_floor [k middle])
     (business_type [k org house_agency])
     (may_own true)
     (req_repute [k respectable])
     (pref_trait1 assertiveness 1.0)
     (pref_trait2 enthusiasm 0.6))

  ; librarian / curator: ENTRY to literature / history (no req_skill).
  (record (job [k job librarian])
     (class_floor [k middle])
     (business_type [k org library])
     (pref_trait1 openness 0.8)
     (pref_trait2 politeness 0.6))

  (record (job [k job curator])
     (class_floor [k middle])
     (business_type [k org museum])
     (pref_trait1 openness 0.8)
     (pref_trait2 politeness 0.6))

  ;; --- Lower-class trades + service (no hard gates - the on-ramp stays open) ---
  (record (job [k job bartender])
     (class_floor [k lower])
     (business_type [k org pub])
     (pref_trait1 enthusiasm 0.8))

  (record (job [k job barber])
     (class_floor [k lower])
     (business_type [k org barbershop])
     (pref_trait1 enthusiasm 0.6))

  (record (job [k job cook])
     (class_floor [k lower])
     (pref_trait1 industriousness 0.6))

  (record (job [k job farmer])
     (class_floor [k lower])
     (pref_trait1 industriousness 0.8))

  (record (job [k job gardener])
     (class_floor [k lower])
     (pref_trait1 industriousness 0.6))

  (record (job [k job maid])
     (class_floor [k lower])
     (pref_trait1 industriousness 0.6)
     (pref_trait2 politeness 0.5))

  ; nurse: a hospital runs round the clock - two shifts in occupation_shifts.hs;
  ; a hire is assigned one (day or night).
  (record (job [k job nurse])
     (class_floor [k lower])
     (business_type [k org hospital])
     (pref_trait1 compassion 1.0)
     (pref_trait2 industriousness 0.6))

  (record (job [k job shop_clerk])
     (class_floor [k lower])
     (business_type [k org grocer])
     (pref_trait1 enthusiasm 0.6)
     (pref_trait2 politeness 0.5))

  (record (job [k job waiter])
     (class_floor [k lower])
     (business_type [k org restaurant])
     (pref_trait1 politeness 0.6)
     (pref_trait2 enthusiasm 0.5))

  ; factory_worker: day AND night shifts - see occupation_shifts.hs.
  (record (job [k job factory_worker])
     (class_floor [k lower])
     (business_type [k org factory])
     (pref_trait1 industriousness 0.6))

  ; jockey: professional race rider, employed by a race_club. The annual
  ; horse_racing meet admits ONLY jockey-job roster entries as riders.
  (record (job [k job jockey])
     (class_floor [k lower])
     (business_type [k org race_club])
     (pref_trait1 assertiveness 0.6)))
