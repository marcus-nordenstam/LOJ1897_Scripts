; ----------------------------------------------------------------------------
; collections - the pile COUNT reads, as funcs.
;
; These were macros. A macro is textual expansion into the caller's var space, and
; these three need a body - a local, a walk over candidates, then a value - which is
; a FUNCTION, not a substitution. As macros their (do ..) handed back the walk's own
; result instead of the closing expression, so every one of them answered @true and
; every (> (believed-home-food-count ..) 0) in the meal lane read false. The pile
; MUTATORS stay macros in collection-macros.mc: they thread an output var by design.
; ----------------------------------------------------------------------------

; (held-pile-count ?who ?kind): the loaf-count ?who BELIEVES it carries in the ?kind
; pile (0 if none) - belief-honest (no /env), so it is legal in a (when). Reading
; one's OWN hand is not telepathy; the perceived {pile count N} is it.
(define-func held-pile-count (?who ?kind)
  (bind 0 ?pile)
  (for-each ?cand (spatial ?who hold [k pile])
    (if {?cand content-kind ?kind}
        (then (bind ?cand ?pile))))
  (if {?pile count ?count} (then ?count) (else 0)))

; (believed-pile-count ?place ?kind): the loaf-count this MIND believes the ?kind pile
; at ?place holds (0 if it believes there is none) - per-mind and no-telepathy. Reads
; the believed contents (never /env) + the perceived {pile count N}.
(define-func believed-pile-count (?place ?kind)
  (bind 0 ?pile)
  (for-each ?cand (spatial ?place contents [k pile])
    (if {?cand content-kind ?kind}
        (then (bind ?cand ?pile))))
  (if {?pile count ?count} (then ?count) (else 0)))

; (believed-home-food-count ?home): the loaf-count this mind believes is in its home
; LARDER (the kitchen pile). The larder lives in the kitchen room, so it resolves the
; believed kitchen first (0 if the mind knows no kitchen).
(define-func believed-home-food-count (?home)
  (bind 0 ?kitchen)
  (bind (spatial ?home room [k kitchen]) ?kitchen)
  (if ?kitchen (then (believed-pile-count ?kitchen [k food])) (else 0)))
