; ----------------------------------------------------------------------------
; collection_macros - the fungible-item PILE vocabulary (see Objects.mon `pile`
; + things.mon (pile)). A pile is ONE self-contained entity standing for N identical
; items: it stores the item KIND (content-kind attr) and a COUNT, never per-item
; entities. A co-present observer mints exactly {pile content-kind [k <kind>]} +
; {pile count N} regardless of N - the memory-compression payoff.
;
; The count is the source of truth; increment/decrement is a single set-attr
; (one perception rule, not N). Extraction spawns a real item OUT of the pile
; (dec + create-entity) and is necessarily content-SPECIFIC because create-entity
; takes only a syntactic [k <kind>] - so the extract site names the kind
; literally; the find/ensure/count/mutate ops below are kind-generic.
; ----------------------------------------------------------------------------

; (pile-at-into ?space ?kind ?out): set ?out to the env pile of content-kind
; ?kind sitting in ?space, leaving it unchanged (0) if none. A find over the
; space's real contents (never belief). The CALLER must declare + zero ?out
; first ((bind 0 ?out)) - a macro's own (do ...) scopes its binds, so the
; output var is threaded in, mutated in place (the forage_at_source idiom).
; Statement form (not a value) because a macro result cannot be `: ?var`-bound.
(define-macro pile-at-into (?space ?kind ?out)
  (for-each ?pile_cand (spatial ?space contents [k pile] /env)
    (if (attr-is ?pile_cand content-kind ?kind)
        (then (bind ?pile_cand ?out)))))

; (held-pile-into ?who ?kind ?out): set ?out to the pile of content-kind ?kind
; that ?who is carrying in hand (env, never belief), or leave it (0) if none.
; CALLER declares + zeroes ?out first.
(define-macro held-pile-into (?who ?kind ?out)
  (for-each ?held_cand (spatial ?who hold [k pile] /env)
    (if (attr-is ?held_cand content-kind ?kind)
        (then (bind ?held_cand ?out)))))

; (pile-add ?pile ?n): raise a pile's count by ?n (one perception rule).
(define-macro pile-add (?pile ?n)
  (set-attr ?pile count (+ (attr ?pile count) ?n)))

; (pile-take ?pile ?n): lower a pile's count by ?n, never below 0.
(define-macro pile-take (?pile ?n)
  (set-attr ?pile count (max 0 (- (attr ?pile count) ?n))))
