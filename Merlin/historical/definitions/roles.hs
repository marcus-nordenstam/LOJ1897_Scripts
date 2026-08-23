; ----------------------------------------------------------------------------
; Shared role-filter macros for hsim events (formerly (define-role ...) templates).
;
; Each is a (define-macro ...) taking the candidate ?x - or @self at a gate. Drop it
; into a (role ...) as a single filter:
;     (role ?b   (any_human ?b)   <extra-filters>...)   ; BIND + enumerate ?b
;     (role @self (grown @self))                        ; GATE the deliberating NPC
; The candidate is passed explicitly (no ?this rewrite): whatever token you pass is
; the subject the body's patterns read.
;
; Multi-criterion predicates bundle with (and ...) plus the believes comma-sugar
; ({?x a, b, c} = a AND b AND c on the shared subject ?x, written once). Every filter
; is a belief-query - kind / liveness / gender / age read from PERCEIVED beliefs (the
; attrs carry (hsim-percept) in common.arc, so a mind internalizes {?o isa <kind>} /
; {?o condition alive} / {?o gender <g>} / {?o age_band <band>} on sight, even for
; strangers; the self mirrors them about @self via update_self_awareness). No
; omniscient (kind ...) / (alive) / (attr ...) / (years-old ...) ops. Age is band-only
; (see macros/age_macros.hs).
;
; A BINDING role (?x) reads the deliberating mind's OWN beliefs ABOUT the candidate
; ({?x <label> ..}) - what the per-(mind, signature) object cache materializes; an
; @self GATE reads its beliefs about itself. (No 2-arg {?x {@self ..}} cross-mind
; reads - those are telepathy and are not object-cacheable.) The light @self gates
; carry no isa/condition (the deliberating NPC is a living human by construction) -
; just the age band.
;
; All filters of one role are membership-tested against the SAME candidate, so a
; multi-filter role is a shared-witness join ({@self home ?h} + {@self own ?h} =
; "owns the home he lives in"). A kind-cast target [k K]:?x (ONE kind, no alts) is
; identity AND is-a against the object's PERMANENT kind - the decay-proof kind test
; on a relation ({@self employer [k org business]:?org}); chain labels (a.b) and
; ground-alts compose as filters too. A filter with a FREE target var
; ({?cand record ?art}) is a cached EXISTENCE criterion that BINDS the var at
; fire time off the drawn candidate - producing binds role-ify too; only
; non-belief ops, dynamic-label binds and act-desire gates stay in (when).
; ----------------------------------------------------------------------------

;; `condition` is @excl, so a learned {?x condition dead} supersedes the earlier
;; {?x condition alive} percept-mirror in that mind - the positive liveness leg
;; alone suffices; no separate not-dead leg.
(define-macro known_alive (?x)
  {?x isa [k human], condition [k alive]})

(define-macro old_human (?x)
  (and (known_alive ?x)
       (marriageable-age ?x)))          ; >=16

;; Any alive human, no age qualifier. Base for events that gate on situational
;; filters (disease, war, accidents) regardless of age.
(define-macro any_human (?x)
  (known_alive ?x))

;; LIGHT @self-only gates - no redundant isa / condition (the deliberating NPC is
;; always a living human). Age-band-only, for (role @self ...).
; Goal reads through the unified belief path (a goal IS a belief
; {@self goal {@self <action> <focus>}} with a nested-clause target; see
; macros/goal_macros.hs). Bound pattern vars constrain; free vars bind off the match.
(define-macro has-goal (?g)
  {@self goal ?g})

(define-macro no-goal (?g)
  (not {@self goal ?g}))

(define-macro grown (?x)
  (marriageable-age ?x))                 ; >=16, old enough to act as an agent

(define-macro adult (?x)
  (adult-age ?x))                        ; >=18

;; Unmarried adult woman. The (not (believes {?x spouse ?})) is the deliberating
;; mind's OWN belief about the candidate's marital status (shape-2), NOT the
;; candidate's self-knowledge (the 2-arg {?x {@self spouse ?}} telepathic read) - so
;; it stays object-cacheable and telepathy-pure: you only skip women YOU know married.
(define-macro unmarried_woman (?x)
  (and (known_alive ?x)
       {?x gender [k female]}
       (adult-age ?x)
       (not {?x spouse ?})))

(define-macro unmarried_man (?x)
  (and (known_alive ?x)
       {?x gender [k male]}
       (adult-age ?x)
       (not {?x spouse ?})))

;; Married woman of fertile age who can conceive NOW - not already carrying a
;; pregnancy ({?x pregnant ?} is set at conception, cleared at delivery by the
;; update_physiology gestation timer). Shape-2 spouse read (the deliberating mind's
;; own belief), so it stays object-cacheable like unmarried_woman.
(define-macro fertile_wife (?x)
  (and (known_alive ?x)
       {?x gender [k female]}
       (working-age ?x)                  ; 16-49 childbearing band
       {?x spouse ?}
       (not {?x pregnant ?})))

;; Adult of working / migration age. Used by emigration.
(define-macro young_adult (?x)
  (and (known_alive ?x)
       (working-age ?x)))                ; 16-49

;; An org the deliberator already KNOWS - a mental org object carrying its kind belief
;; (minted at founding / hire / new_job_orientation when @self reads the org's
;; articles). isa [k org] matches any org kind (is-a); each casting event narrows to
;; its category ([k org club] / business / gov) or excludes household.
(define-macro known_org (?x)
  {?x isa [k org]})

;; A letter / document the deliberating mind has SEEN - perception minted
;; {?x isa [k letter]} (and observable attrs, e.g. {?x addressee ..}) when @self
;; observed it. is-a [k letter] matches every letter subkind (love_letter, tryst_note).
(define-macro any_letter (?x)
  {?x isa [k letter]})
