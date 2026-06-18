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
; FULL templates check (kind human) + (alive) because a BINDING role can land on a
; non-human / dead candidate. The @self GATE never needs those: the deliberating NPC
; is always a living human, so @self gates use the LIGHTER templates (age only).
; ----------------------------------------------------------------------------

(define-role old_human
  (kind [k human])
  (alive)
  (>= (years-old ?this) 15))

;; Any alive human, no age qualifier. Useful as a base for events that gate
;; on situational filters (disease, war, accidents) regardless of age.
(define-role any_human
  (kind [k human])
  (alive))

;; LIGHT @self-only templates - no redundant (kind human) / (alive) (the
;; deliberating NPC is always a living human). Age-only gates for (role @self ...).
(define-role grown
  (>= (years-old ?this) 15))   ; old enough to act as an agent (matches old_human's age)

(define-role adult
  (>= (years-old ?this) 18))

;; Unmarried adult woman. Fertility / marriage age varies by class; events
;; layer extra age filters on top.
;; Merlin's wildcard symbol is bare `?`, so existence checks use `?`.
(define-role unmarried_woman
  (kind [k human])
  (alive)
  (= (attr ?this gender) [k female])
  (>= (years-old ?this) 18)
  (not (believes ?this {@self spouse ?})))

(define-role unmarried_man
  (kind [k human])
  (alive)
  (= (attr ?this gender) [k male])
  (>= (years-old ?this) 18)
  (not (believes ?this {@self spouse ?})))

;; Adult woman in fertile age range, currently married. Births event uses
;; this and recovers the husband via belief query.
(define-role fertile_wife
  (kind [k human])
  (alive)
  (= (attr ?this gender) [k female])
  (>= (years-old ?this) 16)
  (<= (years-old ?this) 42)
  (believes ?this {@self spouse ?}))

;; Adult of working/migration age. Used by emigration.
(define-role young_adult
  (kind [k human])
  (alive)
  (>= (years-old ?this) 16)
  (<= (years-old ?this) 45))

;; An articles_of_incorporation document - the cross-mind anchor of a founded
;; org. The Phase 7 work events role-bind one to name the org they act on.
;; No (alive) filter: a document is not an NPC.
(define-role org_articles
  (kind [k articles_of_incorporation]))
