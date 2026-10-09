; ----------------------------------------------------------------------------
; collections - the pile and ware reads, as funcs.
;
; A read needs a body - a local, a walk over candidates, then a value - which is a
; FUNCTION, not a macro: a macro's (do ..) hands back the walk's own result instead of
; the closing expression.
; ----------------------------------------------------------------------------

; (pile-add ?pile ?count): the one write of a pile's count - ?count units onto it, or off it
; when negative. A pile never goes below empty.
(define-func pile-add (?pile ?count)
  (+ (attr ?pile count) ?count): ?total
  (check (>= ?total 0))
  (set-attr ?pile count ?total))

; (held-ware ?who ?ware): a thing ?who BELIEVES it holds that is ?ware - an instance of
; the kind, or a pile whose content is the kind - or @nothing. What he has stowed is held
; too, so a ware is never matched by the pile kind alone.
(define-func held-ware (?who ?ware)
  (bind @nothing ?held)
  (for-each ?cand (spatial ?who hold)
    (if (or (is-a ?cand ?ware)
            (and (is-a ?cand [k pile]) {?cand content-kind ?ware}))
        (then (bind ?cand ?held)
              (break))))
  ?held)

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
  (if (spatial ?home room [k kitchen])
      (then (believed-pile-count (spatial ?home room [k kitchen]) [k food]))
      (else 0)))
