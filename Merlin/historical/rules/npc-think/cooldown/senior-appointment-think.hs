; ----------------------------------------------------------------------------
; senior_appointment (Phase 9.3). An exemplary, high-prestige adult is
; appointed to a senior public post (church / hospital / agency). The post a
; person holds IS their job / employment state - there is no separate "office"
; concept: this is ordinary employment at a senior rank, gated on exemplary
; character + high prestige + a public (gov-subkind) org.
;
; The candidate leaves their current post first (the (fire ...) is a no-op
; for the jobless), so their `job` (@excl) is free for the gov hire to
; take. The (hire /level senior ...) - rather than /org_head - leaves the
; founder's head slot intact; the head is the position established by
; whoever founded the org. The senior level is the rung that still lifts
; prestige and reads as a senior post downstream.
;
; A senior appointment is an INDIVIDUAL hire, the same act as ordinary `hiring`.
; Identical topology to hiring: role-0 ?official (human, gated + chanced), role-1
; ?articles (the gov org), live-rechecked in (when).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think senior_appointment
  (cooldown 1 m)
  (rng-stream employment)

  ;; The candidate IS the deliberating NPC (@self self-role, the standard
  ;; emergent shape - cf. adult_friendships / betrothal): an exemplary,
  ;; high-prestige adult of working age. The age / repute / prestige floors and
  ;; the trait-product chance now live in (when ...) (role-belief purity); the
  ;; role itself keeps only the belief-pure template. The prestige floor selects
  ;; already-distinguished candidates, naturally targeting the established class.
  ;;
  ;; The plan's "member_of of an organisation that hosts the post" tenure
  ;; gate (PR-A-8 audit) is V2 work - the substrate has the member_of relation
  ;; but the gov-org subset filter would need a cross-role join the .hse layer
  ;; doesn't express cleanly today. V1 routes the chance through a trait
  ;; product: assertiveness + ?prestige above the floor amplifies
  ;; the rate, so a high-prestige assertive candidate fires far more often.
  (role @self (old_human @self)
              {@self repute [k exemplary], prestige ?prestige})
  ;; A public organisation - any gov-subkind: church, hospital, agency. A KNOWN
  ;; org of gov kind (@self learned it at new_job_orientation). Belief-pure + cached.
  (role ?org (known_org ?org)
             [k org gov])

  ;; (chance) FIRST (cheap, short-circuits), then the live exclusivity re-check
  ;; (see betrothal.hs): without it, every gov org enumerated this tick can appoint
  ;; @self before the first appointment commits; once @self is senior this tick it
  ;; fails and the sampler backtracks. The (when) also carries the age / repute /
  ;; prestige floors and the trait-product chance.
  (when (and (chance (* 0.0083
                         (attr @self assertiveness)
                         ?prestige))
             (!= (any {(any {@self job ?}).target level ?}).target [k senior])
             (>= (years-old @self) 30)
             (<= (years-old @self) 65)
             (>= ?prestige 0.65)))

  (effects
    ;; The org's articles (hire-seq's ?var arg - a macro arg used in a pattern must
    ;; be a ?var, not an expr) is recovered from @self's {?org record ?art} belief.
    (any {?org record}).target: ?articles
    ;; Leave the current post (no-op for the jobless), then take up the senior
    ;; public post. hire-seq mints the employment beliefs in @self's own mind
    ;; (no telepathy - @self IS the appointee). fire-first frees the @excl
    ;; job slot so the gov hire takes cleanly.
    (fire-self)
    (hire-seq ?articles [k job official] [k senior])
    ))
