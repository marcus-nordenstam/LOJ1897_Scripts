; ----------------------------------------------------------------------------
; read - THE one document-reading action: take a document's writing into @self's mind.
; Works for ANY document - a letter, a will, a listing, a deed, a register. Getting the
; document into reach, and putting it down / re-filing it afterwards, are the consuming
; task's job (via get / put / stack-browse), never bundled in here.
;
; TWO kinds of writing. SENTENCES (a letter, a will) adopt through the writing codec -
; the sanctioned cross-mind write-through-paper, the written twin of hearing speech:
; @self comes away holding whatever the page asserts. A FORM (a table) asserts nothing
; by itself; what its cells MEAN is content, so READ branches on the document's kind
; and reasons the beliefs out here. A job-posting reads as a VACANCY at a named org: a
; seat known by its org and line with nobody believed to hold it - the same fact @self
; would hold had someone told him "companies house has a clerk's place going" - and the org's door,
; the apply-at cell resolving to a place he imagines off its address until he walks in.
; The org is known by name (imagined until met); the job is imagined outright, a kind
; at an org, no ledger line - a reader never sees the book.
; ----------------------------------------------------------------------------

(include "../../macros/adopt-aoc.mc")

(npc-action {@self READ ?doc}:?read-rel
  (motor eyes legs)
  (obs)
  (tar @excl)
  (presentation
    (preroll 0.0) (in 0.4) (out 0.4))
  (track-skill-level [k literacy])
  (duration (seconds 10 min))
  ; The isim handler validated the document and let the dispatcher roll the act back;
  ; that is the whole of what it did, and it is this. Everything else was already
  ; Merlin's - the .act declared `transmission = read` and the codec adopts the
  ; target's writing into the reader's mind.
  (effects
    (switch (kind ?doc)
      ; A VERDICT letter answers ONE application, and it names which: kind + org. The offer
      ; is minted as a state of the SEAT - {?job offered-to @self}, the seeker's side of the
      ; line the officer pencilled - so accepting can gate on holding an offer for THAT post.
      ; A rejection names the org and nothing of its seats: that place is not going, to him,
      ; and his own applied record is what keeps him from asking again.
      ; The letter names its man (applicant): a housemate reading it learns of the seat and
      ; of no offer to himself (measured: two men at one address each read the other's
      ; letter first and both walked to the counter on it).
      ; An OFFER describes the seat whole - level, salary, shift - so the man holds the job
      ; fully decorated before he walks in; the word at the counter has only to make it his.
      (on [k offer-letter]
        (if (and (form-match (attr ?doc writing) offer_letter_form
                             [/applicant ?vname] [/job-kind ?vjk] [/org-name ?vorg-name]
                             [/job-id ?vline] [/level ?vlevel] [/salary ?vsalary] [/shift ?vshift])
                 (substantial ?vjk) (substantial ?vorg-name) (substantial ?vline))
            (then
              (o [k org] {@o name ?vorg-name}): ?vorg
              (o ?vjk {@o org ?vorg} {@o job-id ?vline}): ?vjob
              (if -{?vjob org ?vorg} (then (begin-belief {?vjob org ?vorg})))
              (if -{?vjob job-id ?vline} (then (begin-belief {?vjob job-id ?vline})))
              ; The description lands once, on the first offer read about this seat.
              (if (and (substantial ?vlevel) (substantial ?vsalary) (substantial ?vshift)
                       -{?vjob level ?})
                  (then (begin-belief {?vjob level ?vlevel})
                        (begin-belief {?vjob salary ?vsalary})
                        (stamp-shift-hours ?vjob ?vjk ?vshift)))
              (if (and (= ?vname (any {@self name ?}).target) -{?vjob offered-to @self})
                  (then (begin-belief {?vjob offered-to @self}))))))
      ; A REJECTION names the seat and nothing more. The same slots as the offer's: one
      ; branch of a switch runs, and the action's slots are counted across all of them.
      (on [k rejection-letter]
        (if (and (form-match (attr ?doc writing) rejection_letter_form
                             [/job-kind ?vjk] [/org-name ?vorg-name] [/job-id ?vline])
                 (substantial ?vjk) (substantial ?vorg-name) (substantial ?vline))
            (then
              (o [k org] {@o name ?vorg-name}): ?vorg
              (o ?vjk {@o org ?vorg} {@o job-id ?vline}): ?vjob
              (if -{?vjob org ?vorg} (then (begin-belief {?vjob org ?vorg})))
              (if -{?vjob job-id ?vline} (then (begin-belief {?vjob job-id ?vline}))))))
      (on [k job-posting]
        (if (and (form-match (attr ?doc writing) job_posting_form
                             [/job-kind ?jk] [/org-name ?org-name] [/job-id ?job-id]
                             [/apply-at ?apply-at])
                 (substantial ?jk) (substantial ?org-name) (substantial ?apply-at))
            (then
              (o [k org] {@o name ?org-name}): ?org
              ; The seat is (org, job-id) - the notice's own reference. Two readings of
              ; ONE vacancy land on one object; two vacancies of the same kind at the
              ; same org stay two. Without the id both collapse into `a clerk's place
              ; there`, which is neither.
              (o ?jk {@o org ?org} {@o job-id ?job-id}): ?job
              (if -{?job org ?org}    (then (begin-belief {?job org ?org})))
              (if -{?job job-id ?job-id} (then (begin-belief {?job job-id ?job-id})))
              (if -{?org workplace ?} (then (begin-belief {?org workplace ?apply-at}))))))
      ; An APPLICATION names a MAN, so reading one is hearing of him: a name and an
      ; address is a specific someone, realis and UNGROUNDED - @self has heard of him
      ; and never met him, and the day he walks in the two fuse on the name. What the
      ; form says is then held about HIM, in the ordinary states anybody is described
      ; by, rather than in a private vocabulary of the paper's own.
      ;
      ; And he APPLIED: a completed apply-for, inferred from the form being on the desk
      ; at all. A born-ended record of another man's act, dated by the form's own date
      ; line, which is how a deed is remembered - not a state invented to stand in for
      ; one. The paper needs no tie to the man beyond that: the apply-for IS the tie.
      ; The WAGE BOOK: one line per seat. The line IS the seat's identity (org, job-id),
      ; so every reader of the same page lands on the same object. The holder's job belief
      ; is what the worker cell says; display-ad is what the advertise-date cell says - the notice
      ; itself hangs on the parish board, this is the firm's own note of it. The offered /
      ; offer-date cells are NOT mirrored: a promise reserves nothing, and the counter
      ; reads them off the page when a man presents himself. The org is whichever one
      ; @self knows keeps this book; a stranger reading it learns nothing of seats.
      ; ARTICLES: the org they declare, its workplace, its book and its current owners.
      (on [k articles-of-incorporation]
        (adopt-aoc ?doc))
      (on [k employee-register]
        (tolerate (any {? employee-register ?doc}): ?erel)
        (if (substantial ?erel)
            (then
              (bind ?erel.subject ?eorg)
              (for-each-row (attr ?doc writing) [/job-id ?eline] [/worker ?ewname] [/job ?ejk]
                            [/advertise-date ?ead]
                (o ?ejk {@o org ?eorg} {@o job-id ?eline}): ?ejob
                (if -{?ejob org ?eorg}      (then (begin-belief {?ejob org ?eorg})))
                (if -{?ejob job-id ?eline}  (then (begin-belief {?ejob job-id ?eline})))
                (if (substantial ?ewname)
                    (then (o [k human] {@o name ?ewname}): ?eworker
                          (if -{?eworker job ?ejob}
                              (then (for-each ?efrel (every {? job ?ejob})
                                      (end-belief ?efrel))
                                    (begin-belief {?eworker job ?ejob}))))
                    (else (for-each ?efrel (every {? job ?ejob})
                            (end-belief ?efrel))))
                (if (substantial ?ead)
                    (then (if -{?eorg display-ad ?ejob}
                              (then (begin-belief {?eorg display-ad ?ejob}))))
                    (else (for-each ?edrel (every {?eorg display-ad ?ejob})
                            (end-belief ?edrel))))))))
      (on [k application]
        (if (and (form-match (attr ?doc writing) application_form
                             [/applicant ?aname] [/home ?ahome] [/job-kind ?ajk]
                             [/org-name ?aorg-name] [/job-id ?aline] [/date ?adate])
                 (substantial ?aname) (substantial ?ahome) (substantial ?ajk)
                 (substantial ?aorg-name) (substantial ?aline) (substantial ?adate))
            (then
              (o [k human] {@o name ?aname}): ?applicant
              (if -{?applicant name ?aname}     (then (begin-belief {?applicant name ?aname})))
              (o [k building] {@o address ?ahome}): ?ahouse
              (if -{?ahouse address ?ahome}     (then (begin-belief {?ahouse address ?ahome})))
              (if -{?applicant home ?ahouse}    (then (begin-belief {?applicant home ?ahouse})))
              ; The SEAT he asked for, by the org's name and the line - the same object the
              ; officer's own book read landed on.
              (o [k org] {@o name ?aorg-name}): ?aorg
              (o ?ajk {@o org ?aorg} {@o job-id ?aline}): ?ajob
              (if -{?ajob org ?aorg}      (then (begin-belief {?ajob org ?aorg})))
              (if -{?ajob job-id ?aline}  (then (begin-belief {?ajob job-id ?aline})))
              (if -{?applicant apply-for ?ajob /ever}
                  (then (begin-belief {?applicant apply-for ?ajob /succ /i ?adate ?adate}))))))
      ; An INVITATION names no occasion - it cannot, an occasion being a nameless
      ; abstract - so it carries what CONSTITUTES one and the reader builds his own
      ; from the cells. Host by name and venue by address are the two referents a
      ; man who has never been told of this gathering can resolve; host + date are
      ; its identity, so two readings of one invitation land on one occasion and
      ; the host's own copy and the guest's refer to the same evening.
      (on [k invitation-letter]
        (if (and (form-match (attr ?doc writing) invitation_letter_form
                             [/occasion-kind ?iokind] [/host ?ihost-name] [/venue ?ivenue]
                             [/held-on ?idate] [/from-hour ?ifrom] [/to-hour ?ito])
                 (substantial ?iokind) (substantial ?ihost-name)
                 (substantial ?idate))
            (then
              (o [k human] {@o name ?ihost-name}): ?ihost
              (o ?iokind {@o host ?ihost} {@o held-on ?idate}): ?iocc
              (if -{?iocc host ?ihost}
                  (then (begin-belief {?iocc host ?ihost})))
              (if -{?iocc held-on ?idate}
                  (then (begin-belief {?iocc held-on ?idate})))
              (if (and (substantial ?ivenue) -{?iocc venue ?})
                  (then (o [k building] {@o address ?ivenue}): ?ivenue-obj
                        (begin-belief {?iocc venue ?ivenue-obj})))
              (if (and (substantial ?ifrom) -{?iocc hours ? ?})
                  (then (begin-belief {?iocc hours ?ifrom ?ito})))
              ; The appointment itself - what the attend chain's guest rung reads.
              (if -{?ihost invite @self ?iocc}
                  (then (begin-belief {?ihost invite @self ?iocc}))))))
      (else (adopt-msg (attr ?doc writing))))
    (set-outcome {@self READ ?doc} /succ)))
