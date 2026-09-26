; ----------------------------------------------------------------------------
; social_macros.mc - relationship-query define-macros.
;
;
; Whom a mind knows, and how well, is read off its bonds: {@self (closeness-labels <tier>) ?x}
; holds for anyone @self holds a bond with at least that close (acquaintance = knows them at
; all), and {@self (kin-labels) ?x} for blood relations. Both folds are declared on the bond
; labels in states.mon ((closeness <tier>), (kin)).
; ----------------------------------------------------------------------------

; (spouse-of ?p): who @self believes ?p is married to. The old C++ op read ?p's
; OWN mind (telepathy - you cannot see another's private spouse belief); this
; reads the ASKER's own knowledge of ?p's marriage. Every call site is @self
; (own spouse - self-knowledge) or the asker's paramour (you know your lover is
; married), so the knowledge is present. present-tense, so a widow(er) reads
; @fail (propagate-death ends the spouse belief everywhere it propagated).
(define-macro spouse-of (?p)
  (any {?p spouse ?}).target)

; (is-attracted-to ?who ?other): does ?who hold an attraction stance of AT LEAST
; the `fancy` band toward ?other? Attraction is a continuous scalar (relational
; stance) that core appraisal projects to a discrete VERB-STATE belief per band -
; fancy(1) < desire(2) < crave(3) - holding exactly the current band. So
; "attraction >= fancy" is "holds ANY of those bands", an options believes
; (the name is is-attracted-to, not fancies, because it matches the stronger
; desire / crave bands too, not just the fancy band).
; This replaces the old opaque (stance-at-least @self ?o fancy) C++ op (which read
; the continuous scalar directly); the belief lags the scalar by up to one tick,
; which is correct - role criteria test BELIEFS, not continuous values.
;
; CANONICAL LADDER: the alts MUST stay in lockstep with the attraction band verbs
; in stance_verb_label() (src/lib/mental/reasoning/shared_functions/appraisal.cc).
(define-macro is-attracted-to (?who ?other)
  {?who fancy|desire|crave ?other})

; (can-write ?actor): is ?actor literate? Folds the old C++ op - the actor's own
; `education` belief (a 0..1 float) vs the 0.30 literacy floor (the threshold is
; now authored here, not a C++ constant).
(define-macro can-write (?actor)
  (>= (any {?actor education}).target 0.30))

; (organizing-occasion [k <kind>]): is @self hosting an occasion of that kind? An
; occasion is a MENTAL OBJECT (its kind is wedding / birthday-party / ...); a [k <kind>]
; target matches an object of that kind by is-a (the belief matcher's object-vs-kind rule).
(define-macro organizing-occasion (?kind)
  {@self organize ?kind})

; Does the deliberator believe ?p keeps a THIRD-PARTY lover: more known lover
; bonds than the benign ones (@self, and ?p's own spouse - stale courtship
; gossip can name either) - the surplus IS an interloper. Pure belief
; arithmetic over the deliberator's own mind; a partner-less anchor reads
; {@fail lover ?} and counts zero, harmlessly.
(define-macro partner-keeps-interloper (?p)
  (> (count (every {?p lover ?}) /float)
     (+ (prob {?p lover @self})
        (prob {?p lover (any {?p spouse ?}).target}))))

; Does the deliberator KNOW of an affair among their own partners: an
; interloper they believe their spouse or a lover keeps. Evidence-mediated:
; the beliefs arrive by witnessing, gossip or abduction, never by reading the
; partner's mind.
(define-macro knows-affair ()
  (or (partner-keeps-interloper (any {@self spouse ?}).target)
      (partner-keeps-interloper (any {@self lover ?}).target)))

