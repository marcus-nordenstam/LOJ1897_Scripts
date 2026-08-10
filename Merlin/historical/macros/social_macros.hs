; ----------------------------------------------------------------------------
; social_macros.hs - relationship-query define-macros.
;
; (personally-knows ?who ?other): does ?who hold ANY referential tie to ?other -
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

; /ever: "has ever met / related to" - an ended tie still means you KNOW the
; person (an ex-lover, a dead parent), and talk_to is a TASK (Tasks.mon), so
; the contact evidence is the ENDED talk acts, not a running conversation.
(define-macro personally-knows (?who ?other)
  (believes {?who friend|acquaintance|spouse|lover|mother|father|sibling|child|talk_to ?other /ever}))

; (spouse-of ?p): who @self believes ?p is married to. The old C++ op read ?p's
; OWN mind (telepathy - you cannot see another's private spouse belief); this
; reads the ASKER's own knowledge of ?p's marriage. Every call site is @self
; (own spouse - self-knowledge) or the asker's paramour (you know your lover is
; married), so the knowledge is present. present-tense, so a widow(er) reads
; @fail (propagate-death ends the spouse belief everywhere it propagated).
(define-macro spouse-of (?p)
  (any {?p spouse ?}).target)

; (is-married ?p): does @self believe ?p has a spouse? Composes spouse-of.
(define-macro is-married (?p)
  (believes {?p spouse @something}))

; (is-betrothed ?p): does @self believe ?p holds a fiancee bond? Asker's-own-
; knowledge, same anti-telepathy fix as spouse-of (the old op read ?p's mind).
(define-macro is-betrothed (?p)
  (believes {?p fiancee @something}))


; (blood-kin ?who ?other): does ?who hold ANY consanguinity bond to ?other - the
; courtship / crush / affair blood-relative exclusion (used as `(not (blood-kin
; @self ?o))`). Expands to a single ground-alts `believes` so the belief read is
; EXPLICIT (the parser sees every kin label -> the object cache can index it),
; replacing the old opaque C++ (kin ...) cross-pair op + its maintained bitset.
;
; CANONICAL SET: this alt-list MUST stay in lockstep with kin_label_names() in
; src/lib/hsim/hsim_strings.h (the C++ source of truth shared by the maintained
; per-holder kin set + the consanguinity triangulation derivations). Add a kin
; label in BOTH places.
(define-macro blood-kin (?who ?other)
  (believes {?who mother|father|parent|sibling|half_sibling|child|cousin|grandparent|grandchild|aunt|uncle|niece|nephew ?other}))

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
  (believes {?who fancy|desire|crave ?other}))

; (can-write ?actor): is ?actor literate? Folds the old C++ op - the actor's own
; `education` belief (a 0..1 float) vs the 0.30 literacy floor (the threshold is
; now authored here, not a C++ constant).
(define-macro can-write (?actor)
  (>= (any {?actor education}).target 0.30))

; (organizing-occasion [k <kind>]): is @self hosting an occasion of that kind? An
; occasion is a MENTAL OBJECT (its kind is wedding / birthday_party / ...); a [k <kind>]
; target matches an object of that kind by is-a (the belief matcher's object-vs-kind rule).
(define-macro organizing-occasion (?kind)
  (believes {@self organize ?kind}))

; Does the deliberator KNOW of an affair among their own partners: an
; interloper they believe their spouse or a lover keeps (interloper-of reads
; the deliberator's own beliefs; a partner-less read @fails harmlessly).
; Evidence-mediated: the belief arrives by witnessing, gossip or abduction,
; never by reading the partner's mind.
(define-macro knows-affair ()
  (or (is-entity (interloper-of (any {@self spouse ?}).target))
      (is-entity (interloper-of (any {@self lover ?}).target))))

; An insult incident WITH its spoken barb: the anchor carries the authored
; barb model (tables/barbs.hs) and the context that picks the ladder. The
; ONE way an insult should be minted - a barbless call mints wordlessly.
(define-macro insult-anchor (?victim ?ctx)
  (incident-anchor @self insult ?victim
    /context        ?ctx
    /barb-ladders   barb_ladders
    /barb-materials barb_materials))
