; ----------------------------------------------------------------------------
; Shared role definitions for hsim events.
;
; A role is referenced from inside an event with:
;     (role ?var (template <name>) <extra-filters>...)
; The body of a (define-role ...) is authored against ?self; ?self gets
; rewritten to the call-site var name at parse time.
; ----------------------------------------------------------------------------

(define-role old_human
  (kind [k human])
  (alive)
  (>= (years-old ?self) 15))

;; Any alive human, no age qualifier. Useful as a base for events that gate
;; on situational filters (disease, war, accidents) regardless of age.
(define-role any_human
  (kind [k human])
  (alive))

;; Unmarried adult woman. Fertility / marriage age varies by class; events
;; layer extra age filters on top.
;; Merlin's wildcard symbol is bare `?`, so existence checks use `?`.
(define-role unmarried_woman
  (kind [k human])
  (alive)
  (= (attr ?self gender) [k female])
  (>= (years-old ?self) 18)
  (not (believes ?self {@self spouse ?})))

(define-role unmarried_man
  (kind [k human])
  (alive)
  (= (attr ?self gender) [k male])
  (>= (years-old ?self) 18)
  (not (believes ?self {@self spouse ?})))

;; Adult woman in fertile age range, currently married. Births event uses
;; this and recovers the husband via belief query.
(define-role fertile_wife
  (kind [k human])
  (alive)
  (= (attr ?self gender) [k female])
  (>= (years-old ?self) 16)
  (<= (years-old ?self) 42)
  (believes ?self {@self spouse ?}))

;; Adult of working/migration age. Used by emigration.
(define-role young_adult
  (kind [k human])
  (alive)
  (>= (years-old ?self) 16)
  (<= (years-old ?self) 45))

;; An articles_of_incorporation document - the cross-mind anchor of a founded
;; org. The Phase 7 work events role-bind one to name the org they act on.
;; No (alive) filter: a document is not an NPC.
(define-role org_articles
  (kind [k articles_of_incorporation]))
