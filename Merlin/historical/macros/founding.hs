; ----------------------------------------------------------------------------
; founding.hs - the org-founding belief sequence, as atomic .hse ops.
;
; This is the DECOMPOSITION of the old monolithic C++ (found-org) effect: the
; documents + every belief the FOUNDER/head holds are minted here, in the .hse DSL,
; over the atomic ops. Only the irreducibly-C++ primitives remain ops:
;   (acquire-org-premises ...) - the spatial verb (acquire an existing unoccupied
;                              building from the pool + the founder's title deed +
;                              an apothecary's poison stock); a dry pool binds ?wp to
;                              a fail value (no abort) and the (if ?wp ...) guard
;                              below skips the founding; see
;                              hsim_org_lifecycle::acquire_org_premises.
;   (stamp-work-hours ...)   - reuse of the occupation-catalog shift stamp that
;                              hire() still depends on (retires with hire(), step 4).
;
; STAFFING is NOT done here. A new org is founded with its HEAD only; the emergent
; labour market staffs it over subsequent ticks from the unemployed pool - the
; role-enumerated `hiring` event (employment.hs) mints an engage_staff goal on a
; jobless adult, hire_errand walks him to the firm, and (hire-matched) commits the
; eligibility-matched hire. No bulk population scan, no immediate catalog headcount.
;
; The head's job is passed as a SCOPED job kind ([k job <role>]) so it serves three
; roles unchanged: the head's job mental-object kind, the roster `job` field, and
; the work-hours catalog key. A plain business passes [k job proprietor].
;
;   (found-org-seq ?org-kind ?head-role)
;     ?org-kind  - the org kind value ([k org church] / a rolled [k org bakery])
;     ?head-role - the founder's job, a scoped job kind ([k job priest])
; ----------------------------------------------------------------------------

(define-macro found-org-seq (?org-kind ?head-role)
  (do
    ; --- spatial premises (C++): acquire an existing building + title deed + stock.
    ; A dry pool binds ?wp to a fail value (no abort); every step below is gated on
    ; (if ?wp ...) so a premises-less founding mints NOTHING - no malformed org, no
    ; error. Founding paths roll only housable kinds, so this is the race / belt path.
    (acquire-org-premises ?org-kind @self (bind ?wp))
    (if ?wp
      (do
        ; --- the org's documents (abs-native): articles + an empty register -------
        (create-entity [k articles_of_incorporation] (qual location ?wp) (bind ?art))
        (create-entity [k employee_register]          (qual location ?wp) (bind ?reg))
        (write-doc-record [k articles_of_incorporation] ?art
            (kind ?org-kind) (founder @self) (building ?wp) (year (year)) (register ?reg))

        ; --- founder's mind: the org object + its constitutive beliefs ------------
        (imagine-or-recall ?org-kind {?art declares_org ?org})
        (begin-belief {?org founder @self})
        (begin-belief {?org workplace ?wp})
        (begin-belief {?org record ?art})

        ; --- seat the founder as HEAD (org_head): roster + employment beliefs -----
        (write-doc-record [k employee_register] ?reg (worker @self) (job ?head-role))
        (begin-belief {@self employer ?org})
        (begin-belief {?wp occupant @self})
        ; the head LEARNS the workplace's rooms (the building's `parts` that are rooms):
        ; {building room <room>} + the reverse {room building <building>}.
        (for-each ?room (attr-values ?wp parts [k interior_space room])
            (begin-belief {?wp room ?room})
            (begin-belief {?room building ?wp}))
        ; the job mental object carrying the org_head rank, plus its work-hours.
        (imagine-or-recall ?head-role {@self job ?job})
        (begin-belief {?job level [k org_head]})
        (stamp-work-hours ?job ?head-role)))))
