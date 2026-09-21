; ----------------------------------------------------------------------------
; spatial.mc - where a thing rests and what a mind has seen of a premises, as content.
;
; A journey has no geometry in it: the coarse leg walks to a venue's bounds HANDLE (the
; engine lands a traveller before a structure's front face), and the near-field leg claims
; a stand cell in front of the venue once it is seen. No rule holds a point.
; ----------------------------------------------------------------------------

(include "../macros/tunables.mc")

; Where a thing set down "at ?dest" comes to rest: a claimed cell of the thing's own size,
; on the floor of a space or on top of anything else. @fail while the grid has no answer
; yet - the asking rung polls until it does - and the claim is the asking rung's: it is
; released when that rung ceases, so no act has to give it back.
(define-func rest-cell (?dest ?item)
  (if (is-a ?dest [k space])
      (then (maintain-claim-env-cell (env-cell-size ?item) [/on_floor_of ?dest]))
      (else (maintain-claim-env-cell (env-cell-size ?item) [/on_top_of ?dest]))))

; ----------------------------------------------------------------------------
; seen-premises-at ?address - the building @self has PERCEIVED at that premises address,
; or @nothing. The negative twin of the role that joins a house to an address: a role can
; join on a value, but a NEGATIVE role reads the per-mind cache alone and has no binding
; env to join with - so "no house I have seen stands there" is asked as a walk.
; ----------------------------------------------------------------------------

(define-func seen-premises-at (?address)
  (bind @nothing ?found)
  (for-each ?rel (every {? address ?address})
    (bind ?rel.subject ?p)
    (if (and (is-a ?p [k building])
             (observed ?p))
      (then
        (bind ?p ?found)
        (break))))
  ?found)
