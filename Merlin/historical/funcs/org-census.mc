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
