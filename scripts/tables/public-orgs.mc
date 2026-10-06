; ----------------------------------------------------------------------------
; public_orgs.mc - the public orgs the town NEEDS, as authored config.
;
; A (define-table ...): implementation config with an inline schema, keyed by the
; plain name `public_orgs`. NOT a world entity and NOT an ontology kind - no NPC
; perceives it; it just tells the founding rule what is foundable. (Contrast
; (define-document ...), for an actual in-world document.) The `kind` field holds
; REAL org kinds (the org founded is a real entity); `class-floor` is the
; founder's minimum class.
;
; Read by world-gen: charter-org files each one's charter, and seat-founding-heads
; seats a founder of the right class at its head.
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
  (record [k church-org]           1700 [k priest]         2 clerk    [k middle])
  (record [k hospital-org]         1700 [k physician]      6 nurse    [k upper])
  (record [k state-school]     1700 [k principal]      4 teacher  [k middle])
  (record [k university]       1700 [k professor]      2 professor [k upper])
  (record [k land-registry]    1700 [k superintendent] 2 clerk    [k lower])
  (record [k company-registry] 1700 [k superintendent] 2 clerk    [k lower])
  (record [k house-agency]     1700 [k superintendent] 2 clerk    [k lower])
  (record [k library-org]          1700 [k librarian]      1 clerk    [k middle])
  (record [k museum-org]           1700 [k curator]        1 clerk    [k middle])
  (record [k theatre-org]          1700 [k superintendent] 1 clerk    [k lower])
  (record [k meeting-hall-org]     1700 [k superintendent] 1 clerk    [k lower])
  (record [k sports-ground-org]    1700 [k superintendent] 1 gardener [k lower]))
