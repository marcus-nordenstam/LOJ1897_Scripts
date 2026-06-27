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
; A BINDING role (?var) re-reads the candidate's own mind; an @self GATE reads the
; deliberating mind. The light @self gates carry no isa/condition (the deliberating
; NPC is a living human by construction) - just the age band.
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
  (not (believes ?this {@self spouse ?})))

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

;; An articles_of_incorporation document - the cross-mind anchor of a founded
;; org. The Phase 7 work events role-bind one to name the org they act on.
;; No (alive) filter: a document is not an NPC.
;; This is the ONE remaining non-belief op in role filters: a document is not yet
;; (hsim-percept), so its kind cannot be read as a perceived belief. Flip to
;; (believes {?this isa [k articles_of_incorporation]}) once documents carry the
;; perceptible-kind flag (deferred with the org_articles document-belief work).
(define-role org_articles
  (kind [k articles_of_incorporation]))
