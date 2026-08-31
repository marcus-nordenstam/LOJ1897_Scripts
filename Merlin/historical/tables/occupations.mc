; ----------------------------------------------------------------------------
; occupations.hs - the job catalog as authored config (a (define-table ...) with
; NAMED records, like businesses / cornerstone_businesses). Loaded from
; historical/tables/ into the .hse catalog; consumed by the (select-row ...)
; hiring match in hire_errand_act.hs - there is NO bespoke C++ parser, struct,
; or catalog (the old hsim_occupations.{h,cc} loader was deleted).
;
; One row per job (a named record: unlisted fields take the (defaults ...) fill):
;   job            - the job kind, [k job <leaf>] (the KEY; matches Concepts.mon).
;   class-floor    - minimum class allowed (HARD hiring gate).
;   business-type  - the org kind that hosts this post, or `none` = generic (a
;                    cook / clerk / maid works anywhere).
;   may-own        - true = a proprietor-grade post. may-own with NO business-type
;                    (landlord / proprietor) is entered by FOUNDING, never hired.
;   req-repute     - HARD: minimum reputation band, or `none`. Trust-sensitive
;                    posts (banking, clerical, the professions) gate on a PROVEN
;                    band - an unappraised repute fails the gate.
;   req-skill + band - HARD: must hold {@self skilled-in <domain>} at >= the band
;                    (novice < trained < expert), or `none`. Education credentials
;                    AND tenure-conferred domain skill are both skilled-in entries,
;                    so this doubles as the EXPERIENCE requirement. ONLY gate
;                    ADVANCED rungs - an ENTRY job must NOT require its own domain
;                    (you learn it on the job), or nobody could be hired into it.
;   pref-trait1/2 + weights - SOFT: preferred personality attrs scoring the match
;                    among the eligible (never block a hire).
;
; THE LADDER (why some jobs carry req-skill and entry jobs do not):
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
  (fields job class-floor business-type may-own req-repute req-skill req-skill-band
          pref-trait1 pref-w1 pref-trait2 pref-w2)
  (defaults none none none false none none none none 0 none 0)

  ;; --- Upper-class professions ---
  (record (job [k job banker])
     (class-floor [k middle])
     (business-type [k org bank])
     (may-own true)
     (req-repute [k respectable])
     (req-skill [k accountancy] [k trained])
     (pref-trait1 industriousness 1.0)
     (pref-trait2 politeness 0.6))

  (record (job [k job industrialist])
     (class-floor [k upper])
     (business-type [k org factory])
     (may-own true)
     (req-repute [k respectable])
     (req-skill [k engineering] [k trained])
     (pref-trait1 assertiveness 1.0)
     (pref-trait2 industriousness 0.8))

  ; landlord / proprietor: may-own with NO business-type - founding-only posts,
  ; skipped by the hiring match.
  (record (job [k job landlord])
     (class-floor [k middle])
     (may-own true)
     (req-repute [k respectable])
     (pref-trait1 assertiveness 0.8)
     (pref-trait2 industriousness 0.6))

  (record (job [k job merchant])
     (class-floor [k middle])
     (business-type [k org shipping-agent])
     (may-own true)
     (pref-trait1 assertiveness 1.0)
     (pref-trait2 enthusiasm 0.6))

  (record (job [k job proprietor])
     (class-floor [k middle])
     (may-own true)
     (pref-trait1 assertiveness 0.8)
     (pref-trait2 industriousness 0.8))

  (record (job [k job solicitor])
     (class-floor [k middle])
     (business-type [k org solicitor-firm])
     (may-own true)
     (req-repute [k respectable])
     (req-skill [k law] [k trained])
     (pref-trait1 industriousness 1.0)
     (pref-trait2 openness 0.5))

  (record (job [k job physician])
     (class-floor [k middle])
     (business-type [k org hospital])
     (req-repute [k respectable])
     (req-skill [k medicine] [k trained])
     (pref-trait1 compassion 0.8)
     (pref-trait2 industriousness 0.8))

  (record (job [k job surgeon])
     (class-floor [k middle])
     (business-type [k org hospital])
     (req-repute [k respectable])
     (req-skill [k medicine] [k trained])
     (pref-trait1 industriousness 1.0)
     (pref-trait2 assertiveness 0.5))

  ; apothecary: may-own + business-type, so entered by founding OR hired as a
  ; junior who learns medicine on the counter (no req-skill - the on-ramp).
  (record (job [k job apothecary])
     (class-floor [k middle])
     (business-type [k org apothecary])
     (may-own true)
     (req-repute [k respectable])
     (pref-trait1 industriousness 0.8))

  ; priest: irregular week (Sunday IS the working day) - see occupation_shifts.hs.
  (record (job [k job priest])
     (class-floor [k middle])
     (business-type [k org church])
     (req-repute [k respectable])
     (pref-trait1 politeness 0.8)
     (pref-trait2 compassion 0.8))

  (record (job [k job principal])
     (class-floor [k middle])
     (business-type [k org private-school])
     (req-repute [k respectable])
     (req-skill [k secondary-school-curriculum] [k trained])
     (pref-trait1 politeness 0.8)
     (pref-trait2 industriousness 0.8))

  ; professor: the university don. Confers no domain - a don's competence is the
  ; degree they earned (minted at graduation), not a skill the post confers.
  (record (job [k job professor])
     (class-floor [k upper])
     (business-type [k org university])
     (req-repute [k respectable])
     (pref-trait1 openness 1.0)
     (pref-trait2 industriousness 0.6))

  ;; --- Middle-class professions ---
  ; editor: the senior newspaper post, reached by a journalist who has built the
  ; literature domain on the job.
  (record (job [k job editor])
     (class-floor [k middle])
     (business-type [k org newspaper])
     (may-own true)
     (req-repute [k respectable])
     (req-skill [k literature] [k trained])
     (pref-trait1 openness 0.8)
     (pref-trait2 assertiveness 0.6))

  ; journalist: ENTRY to the literature domain (no req-skill - learns on the job).
  (record (job [k job journalist])
     (class-floor [k middle])
     (business-type [k org newspaper])
     (pref-trait1 openness 1.0)
     (pref-trait2 enthusiasm 0.6))

  (record (job [k job printer])
     (class-floor [k middle])
     (business-type [k org newspaper])
     (pref-trait1 industriousness 0.8))

  (record (job [k job teacher])
     (class-floor [k middle])
     (business-type [k org state-school])
     (req-repute [k respectable])
     (req-skill [k secondary-school-curriculum] [k novice])
     (pref-trait1 politeness 0.8)
     (pref-trait2 compassion 0.6))

  ; engineer: ENTRY to the engineering domain (the senior rung is industrialist,
  ; which requires engineering trained).
  (record (job [k job engineer])
     (class-floor [k middle])
     (pref-trait1 industriousness 1.0)
     (pref-trait2 openness 0.5))

  ; clerk: ENTRY to accountancy (the senior rung is banker, which requires
  ; accountancy trained). Clerical work needs a respectable name.
  (record (job [k job clerk])
     (class-floor [k middle])
     (req-repute [k respectable])
     (pref-trait1 industriousness 1.0)
     (pref-trait2 politeness 0.5))

  (record (job [k job typist])
     (class-floor [k middle])
     (req-repute [k respectable])
     (pref-trait1 industriousness 0.8))

  (record (job [k job house-agent])
     (class-floor [k middle])
     (business-type [k org house-agency])
     (may-own true)
     (req-repute [k respectable])
     (pref-trait1 assertiveness 1.0)
     (pref-trait2 enthusiasm 0.6))

  ; librarian / curator: ENTRY to literature / history (no req-skill).
  (record (job [k job librarian])
     (class-floor [k middle])
     (business-type [k org library])
     (pref-trait1 openness 0.8)
     (pref-trait2 politeness 0.6))

  (record (job [k job curator])
     (class-floor [k middle])
     (business-type [k org museum])
     (pref-trait1 openness 0.8)
     (pref-trait2 politeness 0.6))

  ;; --- Lower-class trades + service (no hard gates - the on-ramp stays open) ---
  (record (job [k job bartender])
     (class-floor [k lower])
     (business-type [k org pub])
     (pref-trait1 enthusiasm 0.8))

  (record (job [k job barber])
     (class-floor [k lower])
     (business-type [k org barbershop])
     (pref-trait1 enthusiasm 0.6))

  (record (job [k job cook])
     (class-floor [k lower])
     (pref-trait1 industriousness 0.6))

  (record (job [k job farmer])
     (class-floor [k lower])
     (pref-trait1 industriousness 0.8))

  (record (job [k job gardener])
     (class-floor [k lower])
     (pref-trait1 industriousness 0.6))

  (record (job [k job maid])
     (class-floor [k lower])
     (pref-trait1 industriousness 0.6)
     (pref-trait2 politeness 0.5))

  ; nurse: a hospital runs round the clock - two shifts in occupation_shifts.hs;
  ; a hire is assigned one (day or night).
  (record (job [k job nurse])
     (class-floor [k lower])
     (business-type [k org hospital])
     (pref-trait1 compassion 1.0)
     (pref-trait2 industriousness 0.6))

  (record (job [k job shop-clerk])
     (class-floor [k lower])
     (business-type [k org grocer])
     (pref-trait1 enthusiasm 0.6)
     (pref-trait2 politeness 0.5))

  (record (job [k job waiter])
     (class-floor [k lower])
     (business-type [k org restaurant])
     (pref-trait1 politeness 0.6)
     (pref-trait2 enthusiasm 0.5))

  ; factory-worker: day AND night shifts - see occupation_shifts.hs.
  (record (job [k job factory-worker])
     (class-floor [k lower])
     (business-type [k org factory])
     (pref-trait1 industriousness 0.6))

  ; jockey: professional race rider, employed by a race-club. The annual
  ; horse-racing meet admits ONLY jockey-job roster entries as riders.
  (record (job [k job jockey])
     (class-floor [k lower])
     (business-type [k org race-club])
     (pref-trait1 assertiveness 0.6)))
