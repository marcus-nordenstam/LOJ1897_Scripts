; ----------------------------------------------------------------------------
; social_macros.hs - relationship-query define-macros.
;
; {?who friend|acquaintance|spouse|lover|mother|father|sibling|child|talk-to ?other /ever}: does ?who hold ANY referential tie to ?other -
; i.e. has ?who ever met / related to them? Expands to a single ground-alts
; `believes` (the label `A|B|C` matches if the queried mind holds any of those
; bonds). The query ALWAYS runs in the DELIBERATING NPC's own mind, so:
;   - subject @self  -> "do I know ?other" (a self-tie read), and
;   - subject ?third -> "do I believe ?third is tied to ?other" (my knowledge of
;     someone else's ties - NOT telepathy; you generally know who your friends
;     know. A third-party subject needs that knowledge to have spread via gossip
;     / confide / exchange-news first; today every call site is @self, so no
;     spreading channel is required yet).
; This REPLACES the old C++ (personally-knows) op + its cross-pair bitset: one
; name, one concept, routed through the unified believes path.
;
; CANONICAL SET: this alt-list MUST stay in lockstep with
; referential_tie_label_names() in src/lib/hsim/hsim_strings.h (the C++ source of
; truth shared by the co-presence stranger test, the cross-pair discriminator
; index - which depends on the ORDER - and the triangulation derivations). Add a
; tie label in BOTH places.
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
; "attraction >= fancy" is "holds ANY of those bands", a ground-alts believes
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
  (> (count (every {?p lover ?}))
     (+ (prob {?p lover @self})
        (prob {?p lover (any {?p spouse ?}).target}))))

; Does the deliberator KNOW of an affair among their own partners: an
; interloper they believe their spouse or a lover keeps. Evidence-mediated:
; the beliefs arrive by witnessing, gossip or abduction, never by reading the
; partner's mind.
(define-macro knows-affair ()
  (or (partner-keeps-interloper (any {@self spouse ?}).target)
      (partner-keeps-interloper (any {@self lover ?}).target)))

