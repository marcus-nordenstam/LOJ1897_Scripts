; ----------------------------------------------------------------------------
; adopt-aoc - read an articles-of-incorporation FORM into @self's org beliefs.
;
; A page names, it never points: its owners by name, the workplace by its address, and the
; book by its kind - the book carries the org's name - so each resolves to whatever @self
; already knows by that reference, or to one he imagines until he meets it. The owners are
; the entries not struck out; an entry marked is-org names an organisation, any other a
; person. The org object is anchored to the articles themselves ({?art declares-org @o}), so
; two readers of the same articles converge on the same org.
;
;   (adopt-aoc ?art)  - ?art = an articles-of-incorporation document.
; ----------------------------------------------------------------------------

(define-func adopt-aoc (?art)
  (do
    (form-match (attr ?art writing) articles_form
        [/org-kind ?ok] [/org-name ?onm] [/workplace ?owp] [/register ?oreg] [/owners ?oowners])
    (o {?art declares-org @o}): ?org
    (begin-belief {?art declares-org ?org})
    (begin-belief {?org isa ?ok})
    (begin-belief {?org name ?onm})
    (o [k building] {@o address ?owp}): ?aoc-wp
    (if -{?aoc-wp address ?owp} (then (begin-belief {?aoc-wp address ?owp})))
    (begin-belief {?org workplace ?aoc-wp})
    ; WHICH relation the book mints is read off the document itself, never guessed from the
    ; org: a wage register and a membership roll carry different columns.
    (o ?oreg {@o name ?onm}): ?aoc-book
    (if -{?aoc-book name ?onm} (then (begin-belief {?aoc-book name ?onm})))
    (if (is-a ?oreg [k employee-register])
        (then (begin-belief {?org employee-register ?aoc-book})))
    (if (is-a ?oreg [k membership-roll])
        (then (begin-belief {?org membership-roll ?aoc-book})))
    (for-each-row ?oowners [/owner ?aoc-oname] [/is-org ?aoc-oorg] [/struck ?aoc-ostruck]
      (if (not ?aoc-ostruck)
          (then (bind (if ?aoc-oorg
                            (then (o [k org] {@o name ?aoc-oname}))
                            (else (o [k human] {@o name ?aoc-oname})))
                        ?aoc-owner)
                (if -{?aoc-owner name ?aoc-oname}
                    (then (begin-belief {?aoc-owner name ?aoc-oname})))
                (if -{?aoc-owner own ?org} (then (begin-belief {?aoc-owner own ?org}))))))))
