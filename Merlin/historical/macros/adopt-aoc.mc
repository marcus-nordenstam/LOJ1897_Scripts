; ----------------------------------------------------------------------------
; adopt-aoc - convert an articles-of-incorporation TABLE into @self's org beliefs.
;
; The table replaces the old (written-msg ...) form: its one row holds the org's
; kind / name / founder / workplace / employee-register as plain cells (a table is
; NOT a message, so generic (adopt-msg ...) would mint nothing from it - it must be
; decoded explicitly here). The org object is anchored to the articles themselves
; ({?art declares-org @o}), so two readers of the same AOC converge on the same org;
; the optional cells (name / founder / register) mint only when present, so an infra
; org filed with @nothing in those columns adopts cleanly. Mirrors what the msg-form
; adopt did: {?art declares-org ?org} + {?org isa/name/founder/workplace/register}.
;
;   (adopt-aoc ?art)  - ?art = an articles-of-incorporation document.
; ----------------------------------------------------------------------------

(define-macro adopt-aoc (?art)
  (for-each-row (attr ?art writing)
      (org-kind ?ok) (org_name ?onm) (founder ?ofr) (workplace ?owp) (register ?oreg)
      (o {?art declares-org @o}): ?org
      (begin-belief {?art declares-org ?org})
      (begin-belief {?org isa ?ok})
      (if (substantial ?onm)  (then (begin-belief {?org name ?onm})))
      (if (substantial ?ofr)  (then (begin-belief {?org founder ?ofr})))
      (if (substantial ?owp)  (then (begin-belief {?org workplace ?owp})))
      (if (substantial ?oreg) (then (begin-belief {?org employee-register ?oreg})))))
