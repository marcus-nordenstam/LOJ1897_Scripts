; fill-post - @self takes a job: his name goes into the vacant line's worker cell, IN
; PLACE. The line must not move - a job IS its line on this ledger, so striking and
; re-appending would hand the advertised job to a different line and the notice would
; never come down. No vacant line of that kind (a head's seat, a job outside the
; establishment) -> nothing to fill, so a line is added, numbered after the last.
; Already on the book for it -> nothing to do (a second signing never duplicates a line).
;
; Signing a man on SPENDS whatever promise stood against the line: the offer has been
; taken up, so the pencil goes and the seat is his outright.
(define-func fill-post (?reg ?job-kind ?level)
  (if (not (table-match (attr ?reg writing) worker (name @self) job ?job-kind))
      (then
        (if (not (table-set ?reg (where worker @nothing job ?job-kind)
                                 worker (name @self) level ?level
                                 hiring-date (time date)
                                 offered @nothing offer-date @nothing))
            (then
              (bind 0 ?fp-line)
              (for-each-row (attr ?reg writing) [/job-id ?fp-seen]
                (bind ?fp-seen ?fp-line))
              (table-add ?reg job-id (+ ?fp-line 1)
                              worker (name @self) job ?job-kind level ?level
                              hiring-date (time date)
                              shift (draw-shift ?job-kind)))))))

; stamp-work-hours - the shift stamp. Reads the authored occupation_shifts rows for
; ?job-kind (falling back to the `default` Mon-Sat week when the kind has none) and
; mints one {?job <day>-hours <start> <end>} belief per day of ONE shift. A kind
; authored under several shift-ids (nurse / factory-worker: day AND night) puts the
; worker on exactly one, drawn here.
; stamp-shift-hours - the day-hours beliefs of ONE authored shift of ?job-kind on ?job:
; what a reader of the offer letter mints from its shift line, and what the officer holds
; of the seat he keeps.
(define-func stamp-shift-hours (?job ?job-kind ?ssh-shift)
  (do
    (if (table-match occupation_shifts job ?job-kind)
        (then ?job-kind)
        (else [k job])): ?ssh-key
    (for-each-row occupation_shifts
        [/job ?ssh-j] [/shift-id ?ssh-sid] [/day-label ?ssh-day]
        [/start-h ?ssh-start] [/end-h ?ssh-end]
      (if (and (= ?ssh-j ?ssh-key) (= ?ssh-sid ?ssh-shift))
          (then (begin-belief {?job ?ssh-day ?ssh-start ?ssh-end}))))))

; name-premises - an org that NAMES its building (businesses names-building = yes: a pub, a
; hotel, a factory) gives the building its `name` and hangs the building-name-sign. The
; name is the BUILDING's from then on - it is the premises' identity, not the org's, so a
; building already named keeps its name (first namer wins; a later tenant works "at the
; Laughing Pig"). The sign is a structural PART of the building at a zero local offset,
; which puts it on the fixture walk perception runs when the building itself is perceived.
; An org that does not name its building mounts nothing: the building's address is its
; identity, and an org has no sign of its own.
(define-func name-premises (?bldg ?org-kind ?org-name)
  (do
    (bind ?bldg ?np-bldg)
    (bind ?org-name ?np-name)
    (table-match businesses org-kind ?org-kind names-building ?np-names)
    (if (and (substantial ?np-name)
             (= ?np-names yes)
             (not (substantial (attr ?np-bldg name))))
      (then
        (set-attr ?np-bldg name ?np-name)
        (create-entity [k building-name-sign] @nothing ?np-bldg): ?np-sign
        (set-attr ?np-sign name ?np-name)))))

; delist ?b - pull building ?b's row off every for-sale register.
(define-func delist (?b)
  (for-each ?listings (env-entities [k for-sale-listings])
    (table-remove ?listings building (attr ?b address))))

; file-articles - write an org's articles and file them at the companies house (the company
; registry's incorporation stack), not the org's own premises - the town's org record lives
; there. The page names the founder by his name (@nothing for a charter), the premises by
; their address and the book by its kind; the book itself is titled with the org's name,
; which is how a reader of the articles knows it when he sees it.
(define-func file-articles (?art ?fa-kind ?fa-name ?fa-wp ?fa-book)
  (do
    (set-attr ?fa-book name ?fa-name)
    (attr ?fa-wp address): ?fa-addr
    (kind ?fa-book): ?fa-book-kind
    (set-writing ?art (table-msg articles_form [[org-kind ?fa-kind] [org-name ?fa-name]
                                                [workplace ?fa-addr] [register ?fa-book-kind]]))
    (head (env-entities [k incorporation-stack])): ?fa-ist
    (check ?fa-ist)
    (push ?art ?fa-ist)))

; take-premises - the head takes possession of the org's building: he SEES it and its rooms
; (a placement write resolves passively, so an unseen room cannot be written about) and
; learns which building they belong to. Owning the premises stands in for exploring them.
(define-func take-premises (?wp)
  (do
    (observe ?wp)
    (for-each ?room (spatial ?wp parts [k room] /env)
      (observe ?room)
      (spatial-write ?room struct_parent ?wp))))

; seat-org-head - the MENTAL half of founding, shared by every route into a head seat. The
; head gets his org object the same way anyone else does: he LOOKS AT the articles and READS
; them through adopt-aoc, the one decoder (ORIENT and hire-beliefs call it too) - no
; privileged minting. adopt-aoc anchors the org to the articles, so the org is READ BACK off
; that anchor rather than searched for a second time. Heading is NOT employment - no salary.
(define-func seat-org-head (?art ?wp ?reg ?head-role)
  (do
    (observe ?art)
    (observe ?reg)
    (adopt-aoc ?art)
    (o {?art declares-org @o}): ?org
    (begin-belief {?org record ?art})
    (fill-post ?reg ?head-role [k senior])
    (begin-belief {?wp occupant @self})
    ; The head's seat is a ledger line like any other - keyed on it, so his own job object
    ; is the one every later reader of this book lands on.
    (if (table-match (attr ?reg writing) worker (name @self) job ?head-role job-id ?soh-line
                                          shift ?soh-shift)
        (then
          (o ?head-role {@o org ?org} {@o job-id ?soh-line}): ?job
          (begin-belief {?job org ?org})
          (begin-belief {?job job-id ?soh-line})
          (begin-belief {@self job ?job})
          (begin-belief {?job level [k senior]})
          (begin-belief {?job since (time year)})
          (stamp-shift-hours ?job ?head-role ?soh-shift)))))

(define-func fire-self ()
  (for-each ?job (every {@self job ?})
      (bind ?job.target ?fire-job)
      (for-each ?org (every {?fire-job org ?})
          (bind ?org.target ?fire-org)
          (for-each ?employee-register (every {?fire-org employee-register ?})
              (bind ?employee-register.target ?fire-reg)
              (table-set ?fire-reg (where worker (name @self))
                              worker @nothing level @nothing hiring-date @nothing)))
      (end-belief ?job)))

; establish-posts - stamp a fresh register with THE schema and file the org's authored
; staff posts on it, all vacant. The header and the rows that fill it are written
; together, in one place: spelled per-site, they drifted (`line` against `job-id`) and
; every business's establishment came out blank.
(define-func establish-posts (?reg ?org-kind)
  (do
    (table-init ?reg job-id job worker level hiring-date offered offer-date advertise-date shift)
    (if (table-match org_staffing org-kind ?org-kind staff-role ?ep-role)
      (then
        (bind 0 ?ep-line)
        (repeat (if (table-match public_orgs kind ?org-kind employee-count ?ep-n)
                    (then ?ep-n)
                    (else (k-default-staff-posts)))
          (do
            (bind (+ ?ep-line 1) ?ep-line)
            (table-add ?reg job-id ?ep-line worker @nothing job ?ep-role
                            shift (draw-shift ?ep-role))))))))
