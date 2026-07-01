; ----------------------------------------------------------------------------
; Shared role definitions for hsim events.
;
; A template is referenced from inside an event with:
;     (role ?var  (template <name>) <extra-filters>...)   ; BIND + enumerate ?var
;     (role @self (template <name>) <extra-filters>...)   ; GATE the deliberating NPC
; The body of a (define-role ...) is authored against ?this (the template-local
; self-ref); ?this is rewritten to the call-site target at parse time - to ?var for
; a binding role, or to @self for a gate.
;
; Every filter is a belief-query: kind / liveness / gender / age are all read
; from PERCEIVED beliefs (the attrs carry (hsim-percept) in common.arc, so a mind
; internalizes {?o isa <kind>} / {?o condition alive} / {?o gender <g>} /
; {?o age_band <band>} on sight - even for strangers - and the self mirrors them
; about @self via update_self_awareness). No omniscient (kind ...) / (alive) /
; (attr ...) / (years-old ...) ops remain. Age is band-only (see age_macros.hs).
;
; Every filter reads the DELIBERATING mind: a BINDING role (?var) is the
; deliberating mind's own beliefs ABOUT the candidate ({?var <label> ..}), which
; is what the per-(mind, signature) object cache materializes; an @self GATE reads
; its beliefs about itself. (No 2-arg {?var {@self ..}} cross-mind reads - those
; are telepathy and are not object-cacheable.) The light @self gates carry no
; isa/condition (the deliberating NPC is a living human by construction) - just
; the age band.
; ----------------------------------------------------------------------------

(define-role old_human
  (believes {?this isa [k human]})
  (believes {?this condition [k alive]})
  (marriageable-age ?this))   ; >=16 (was numeric >=15; nearest band boundary)

;; Any alive human, no age qualifier. Useful as a base for events that gate
;; on situational filters (disease, war, accidents) regardless of age.
(define-role any_human
  (believes {?this isa [k human]})
  (believes {?this condition [k alive]}))

;; LIGHT @self-only templates - no redundant isa / condition (the deliberating
;; NPC is always a living human). Age-band-only gates for (role @self ...).
(define-role grown
  (marriageable-age ?this))   ; old enough to act as an agent; >=16 (was >=15)

(define-role adult
  (adult-age ?this))          ; >=18

;; Unmarried adult woman. Fertility / marriage age varies by class; events
;; layer extra age filters on top.
;; Merlin's wildcard symbol is bare `?`, so existence checks use `?`.
(define-role unmarried_woman
  (believes {?this isa [k human]})
  (believes {?this condition [k alive]})
  (believes {?this gender [k female]})
  (adult-age ?this)
  ; The deliberating mind's OWN belief about the candidate's marital status
  ; (shape-2, {?this spouse ?}), NOT the candidate's self-knowledge (the 2-arg
  ; {?this {@self spouse ?}} telepathic read) - so this is object-cacheable and
  ; telepathy-pure: you only skip women YOU know to be married.
  (not (believes {?this spouse ?})))

(define-role unmarried_man
  (believes {?this isa [k human]})
  (believes {?this condition [k alive]})
  (believes {?this gender [k male]})
  (adult-age ?this)
  (not (believes ?this {@self spouse ?})))

;; Adult woman in fertile age range, currently married. Births event uses
;; this and recovers the husband via belief query.
(define-role fertile_wife
  (believes {?this isa [k human]})
  (believes {?this condition [k alive]})
  (believes {?this gender [k female]})
  (working-age ?this)         ; 16-49 childbearing band (was numeric 16-42)
  (believes ?this {@self spouse ?}))

;; Adult of working/migration age. Used by emigration.
(define-role young_adult
  (believes {?this isa [k human]})
  (believes {?this condition [k alive]})
  (working-age ?this))        ; 16-49 (was numeric 16-45)

;; An org the deliberator already KNOWS - a mental org object carrying its kind
;; belief (minted at founding / hire / new_job_orientation when @self reads the
;; org's articles). This is the belief-pure successor to org_articles: the casting
;; events role over orgs @self has learned, not over every articles document in
;; the world. `isa [k org]` matches any org kind (is-a); each casting event then
;; narrows to its category ([k org club] / business / gov) or excludes household.
(define-role known_org
  (believes {?this isa [k org]}))

;; A letter / document the deliberating mind has SEEN - perception minted
;; {?this isa [k letter]} (and its observable attrs, e.g. {?this addressee ..})
;; when @self observed it in their space or their own secret cache. Roles can
;; bind ANY entity, not just people; the mail-reading routine casts letters this
;; way. is-a [k letter] matches every letter subkind (love_letter, tryst_note ..).
(define-role any_letter
  (believes {?this isa [k letter]}))
