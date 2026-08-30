; ----------------------------------------------------------------------------
; collection_macros - the fungible-item PILE vocabulary (see Objects.mon `pile`
; + pile.arc). A pile is ONE self-contained entity standing for N identical
; items: it stores the item KIND (content_kind attr) and a COUNT, never per-item
; entities. A co-present observer mints exactly {pile content_kind [k <kind>]} +
; {pile count N} regardless of N - the memory-compression payoff.
;
; The count is the source of truth; increment/decrement is a single set-attr
; (one perception rule, not N). Extraction spawns a real item OUT of the pile
; (dec + create-entity) and is necessarily content-SPECIFIC because create-entity
; takes only a syntactic [k <kind>] - so the extract site names the kind
; literally; the find/ensure/count/mutate ops below are kind-generic.
; ----------------------------------------------------------------------------

; (pile-at-into ?space ?kind ?out): set ?out to the env pile of content_kind
; ?kind sitting in ?space, leaving it unchanged (0) if none. A find over the
; space's real contents (never belief). The CALLER must declare + zero ?out
; first ((bind 0 ?out)) - a macro's own (do ...) scopes its binds, so the
; output var is threaded in, mutated in place (the forage_at_source idiom).
; Statement form (not a value) because a macro result cannot be `: ?var`-bound.
(define-macro pile-at-into (?space ?kind ?out)
  (for-each ?pile_cand (spatial ?space contents [k pile] /env)
    (if (attr-is ?pile_cand content_kind ?kind)
        (then (bind ?pile_cand ?out)))))

; (held-pile-into ?who ?kind ?out): set ?out to the pile of content_kind ?kind
; that ?who is carrying in hand (env, never belief), or leave it (0) if none.
; CALLER declares + zeroes ?out first.
(define-macro held-pile-into (?who ?kind ?out)
  (for-each ?held_cand (spatial ?who hold [k pile] /env)
    (if (attr-is ?held_cand content_kind ?kind)
        (then (bind ?held_cand ?out)))))

; (pile-add ?pile ?n): raise a pile's count by ?n (one perception rule).
(define-macro pile-add (?pile ?n)
  (set-attr ?pile count (+ (attr ?pile count) ?n)))

; (pile-take ?pile ?n): lower a pile's count by ?n, never below 0.
(define-macro pile-take (?pile ?n)
  (set-attr ?pile count (max 0 (- (attr ?pile count) ?n))))

; (believed-home-food-count ?home): the loaf-count this mind believes is in its
; home LARDER (the kitchen pile). The larder lives in the kitchen room,
; so it resolves the believed kitchen first (0 if the mind knows no kitchen).
(define-macro believed-home-food-count (?home)
  (do
    (bind 0 ?bhf_kitchen)
    (spatial ?home room [k kitchen]): ?bhf_kitchen
    (if ?bhf_kitchen (then (believed-pile-count ?bhf_kitchen [k food])) (else 0))))

; (held-pile-count ?who ?kind): the loaf-count ?who BELIEVES it carries in the
; ?kind pile (0 if none) - belief-honest (no /env), so it is legal in a (when).
; Reading one's OWN hand is not telepathy; the perceived {pile count N} is it.
(define-macro held-pile-count (?who ?kind)
  (do
    (bind 0 ?hpc_pile)
    (for-each ?hpc_cand (spatial ?who hold [k pile])
      (if {?hpc_cand content_kind ?kind}
          (then (bind ?hpc_cand ?hpc_pile))))
    (if ?hpc_pile (then (prob {?hpc_pile count ?})) (else 0))))

; (believed-pile-count ?place ?kind): the loaf-count this MIND believes the
; ?kind pile at ?place holds (0 if it believes there is none) - per-mind and
; no-telepathy. Reads the believed contents (never /env) + the perceived {pile count N}.
(define-macro believed-pile-count (?place ?kind)
  (do
    (bind 0 ?bpc_pile)
    (for-each ?bpc_cand (spatial ?place contents [k pile])
      (if {?bpc_cand content_kind ?kind}
          (then (bind ?bpc_cand ?bpc_pile))))
    (if ?bpc_pile (then (prob {?bpc_pile count ?})) (else 0))))
