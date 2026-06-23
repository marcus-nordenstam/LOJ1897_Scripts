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

(define-macro personally-knows (?who ?other)
  (believes {?who friend|acquaintance|spouse|lover|mother|father|sibling|child|talk_to ?other}))
