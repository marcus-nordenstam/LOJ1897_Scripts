; ----------------------------------------------------------------------------
; count-orgs-isa - the town's live org census, read straight off the incorporation
; documents (no @gm registry attr). Scans every articles_of_incorporation and counts
; the ones whose org_kind cell is-a ?kind, returning the tally. A closed org's AOC is
; destroyed at wind-up, so the scan is self-pruning: it counts only live orgs.
;
; A mental-only VALUE func (returns the count) - usable in a (when) gate or an
; effect. Callers: found_public_org / found_cornerstone_business ((= .. 0) = the
; one-per-kind cap) and business_homeostat (the org-supply floor throttle).
;
;   (count-orgs-isa [k org K])  - how many live orgs is-a K.
; ----------------------------------------------------------------------------

(define-func count-orgs-isa (?kind)
  (bind 0 ?n)
  (for-each ?art (env-entities [k articles_of_incorporation])
    (if (table-match (attr ?art writing) org_kind ?kind) (then (+= ?n 1))))
  ?n)

; ----------------------------------------------------------------------------
; headless-charter - the first charter of ?kind that nobody heads yet, or @nothing.
;
; Returns @nothing rather than @fail on a miss: a `:`-bind of @fail ABORTS the rest of the
; sequence, and a founder scanning the config table for a post he could take must be free to
; try the next row. Gate the answer with (substantial ...).
; ----------------------------------------------------------------------------

(define-func headless-charter (?kind)
  (bind @nothing ?found)
  (for-each ?art (env-entities [k articles_of_incorporation])
    (if (table-match (attr ?art writing) org_kind ?kind founder @nothing)
      (then
        (bind ?art ?found)
        (break))))
  ?found)

; ----------------------------------------------------------------------------
; charter-for - the first headless charter ?who could actually take up (his class meets
; the kind's floor, in either founding table), or @nothing.
;
; This is the startup founding rules' DEMAND GATE, and it is what lets the startup pass
; QUIESCE. A round-based pass stops when a round fires nothing, and a rule FIRES whenever
; its gates pass - whether or not its effects change anything. Without this gate every
; eligible adult re-fires a fruitless scan every round, so the pass never quiesces and
; always burns the full round cap.
; ----------------------------------------------------------------------------

(define-func charter-for (?who)
  (bind @nothing ?found)
  (for-each ?art (env-entities [k articles_of_incorporation])
    (for-each-row (attr ?art writing) (org_kind ?ok) (founder ?ofr)
      (if (= ?ofr @nothing)
        (then
          (if (table-match public_orgs kind ?ok class_floor ?pcf)
            (then
              (if (class-at-least ?who ?pcf) (then (bind ?art ?found)))))
          (if (table-match cornerstone_businesses kind ?ok class_floor ?ccf)
            (then
              (if (class-at-least ?who ?ccf) (then (bind ?art ?found)))))))))
  ?found)
