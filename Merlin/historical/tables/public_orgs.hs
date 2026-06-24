; ----------------------------------------------------------------------------
; public_orgs.hs - the public orgs the town NEEDS, as authored config.
;
; A (define-table ...): implementation config with an inline schema, keyed by the
; plain name `public_orgs`. NOT a world entity and NOT an ontology kind - no NPC
; perceives it; it just tells the founding event what is foundable. (Contrast
; (define-document ...), for an actual in-world document.) The `kind` field holds
; REAL org kinds (the org founded is a real entity); `class_floor` is the
; founder's minimum class.
;
; Read by the (startup) found_public_org event via (for-each-table-record ...):
; each eligible NPC founds a still-needed org of their class. Replaces the C++
; public_orgs.hsc catalog + the bootstrap founding.
; ----------------------------------------------------------------------------

(define-table public_orgs
  (fields kind era_min head_pos employee_count employee_role class_floor)
  (record [k org church]           1700 priest    2 clerk    [k middle])
  (record [k org hospital]         1700 physician 6 nurse    [k upper])
  (record [k org agency]           1700 clerk     3 clerk    [k lower])
  (record [k org state_school]     1700 principal 4 teacher  [k middle])
  (record [k org university]       1700 professor 2 professor [k upper])
  (record [k org land_registry]    1700 clerk     2 clerk    [k lower])
  (record [k org company_registry] 1700 clerk     2 clerk    [k lower])
  (record [k org library]          1700 librarian 1 clerk    [k middle])
  (record [k org museum]           1700 curator   1 clerk    [k middle])
  (record [k org theatre]          1700 clerk     1 clerk    [k lower])
  (record [k org meeting_hall]     1700 clerk     1 clerk    [k lower])
  (record [k org sports_ground]    1700 clerk     1 gardener [k lower]))
