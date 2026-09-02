; ----------------------------------------------------------------------------
; public_orgs.hs - the public orgs the town NEEDS, as authored config.
;
; A (define-table ...): implementation config with an inline schema, keyed by the
; plain name `public_orgs`. NOT a world entity and NOT an ontology kind - no NPC
; perceives it; it just tells the founding rule what is foundable. (Contrast
; (define-document ...), for an actual in-world document.) The `kind` field holds
; REAL org kinds (the org founded is a real entity); `class-floor` is the
; founder's minimum class.
;
; Read by the (startup) found_public_org rule via (for-each-table-record ...):
; each eligible NPC founds a still-needed org of their class. Replaces the C++
; public_orgs.hsc catalog + the bootstrap founding.
; ----------------------------------------------------------------------------

; head-pos is the founder's job as a SCOPED job kind ([k job <role>]): the founding
; macro mints the head's job mental object + roster entry + work-hours from it
; directly. employee-role stays a bare atom (staff-org -> hire resolves it).
; head-pos MUST be a HEAD kind (is-a head-of-non-household-org) - the one-org
; founding cap and the duty argmax read head-ness off the job kind (the civic
; facilities seat a superintendent). ONE deliberate exception: the university's
; head is duty-assigned among its professors (professor stays a STAFF kind).
(define-table public_orgs
  (fields kind era-min head-pos employee-count employee-role class-floor)
  (record [k org church]           1700 [k job priest]         2 clerk    [k middle])
  (record [k org hospital]         1700 [k job physician]      6 nurse    [k upper])
  (record [k org state-school]     1700 [k job principal]      4 teacher  [k middle])
  (record [k org university]       1700 [k job professor]      2 professor [k upper])
  (record [k org land-registry]    1700 [k job superintendent] 2 clerk    [k lower])
  (record [k org company-registry] 1700 [k job superintendent] 2 clerk    [k lower])
  (record [k org house-agency]     1700 [k job superintendent] 2 clerk    [k lower])
  (record [k org library]          1700 [k job librarian]      1 clerk    [k middle])
  (record [k org museum]           1700 [k job curator]        1 clerk    [k middle])
  (record [k org theatre]          1700 [k job superintendent] 1 clerk    [k lower])
  (record [k org meeting-hall]     1700 [k job superintendent] 1 clerk    [k lower])
  (record [k org sports-ground]    1700 [k job superintendent] 1 gardener [k lower]))
