; ----------------------------------------------------------------------------
; resolve-applications - the recruit officer's verdict round over the application FORMS
; still in his hand. The PAPER is the queue: he owes an answer to every form he holds,
; and a form is destroyed by the draft-verdict that answers it, so the round drains to
; empty and concludes. @self believes NOTHING about the men named on them - they are
; names on paper until one walks through his door.
;
; ONE decision per OPEN POST: the first applicant for its kind gets it, pencilled against
; the LINE as {?job offered-to ?applicant}. That is the one place a man @self has never
; met becomes an OBJECT, and it has to: a seat promised is promised to somebody, and
; offered-to takes a human. He is built from what the form says - a name and an address -
; and carries no claim about what he is doing. The day he comes to take the post up, the
; man at the counter and this paper man fuse on the name, and the promise lands on him.
;
; A REJECTED applicant becomes no object at all. His letter is addressed off the form.
;
; A form ALREADY ANSWERED is off the list, and ONLY that test. It must not also exclude a
; form whose draft is RUNNING: maintain-proposal holds an act only while its rung keeps
; passing, so a -{.. /pres} guard here goes false the instant draft-verdict is promoted,
; the rung stops holding, its utility source is removed, and the engine withdraws the very
; task it just started (/interrupted, k_end_proposal_withdrawn - measured: admitted and
; vanished in the same cycle, six times). A guard that fires on your own act kills it.
;
; Nor an /ever record: a draft cut off at five o'clock concluded nothing and answered
; nobody, and that form would then sit in his hand for good.
;
; ANSWERING IS THE DUTY, so both drafting rungs carry it at the duty's own band. They
; used to ride (utility fallback), which is not a low band but a PIN TO THE FLOOR of the
; auction - "only if the body has nothing else at all to do". At his post the body always
; has something else: DWELL, standing at the counter. So the letter lost every auction it
; ever entered and no verdict was ever written (measured: CREATE-ENTITY [k offer-letter]
; proposed 6 times at idle:0, beaten by DWELL every time).
;
; No relative order between them - they are mutually exclusive by construction, one on a
; standing offer for this name and the other on the absence of one.
;
; Both drafting rungs take the lock and answer ONE form at a time: two drafts at once
; propose the very same create-a-letter act, and one letter cannot answer two men.
; ----------------------------------------------------------------------------

(npc-task {@self resolve-applications}:?rt-rel
  (track-skill-level [k personnel])
  (and
    ; PENCIL THE SEAT AGAINST A MAN. An open line, and a form in hand asking for that kind
    ; of work. The object is minted here and only here; (o ..) resolves to the one already
    ; standing if @self has met him before, so a former employee re-applying does not
    ; become a second man.
    (try
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?job {?job org ?org}
                 {?job job-id ?}
                 -{?job filled-by ?}
                 -{?job offered-to ?})
      (role ?app [k application] (spatial ?app held-by @self)
                                 {@self READ ?app /succ}
                                 -{@self draft-verdict ?app ? /succ})
      (when (and (table-match (attr ?app writing) field job value ?jk)
                 (table-match (attr ?app writing) field applicant value ?name)
                 (table-match (attr ?app writing) field home value ?addr)
                 (is-a ?job ?jk)))
      (effects
        (o [k human] {@o name ?name} {@o address ?addr}): ?applicant
        ; ONE offer per man in flight: a seat already promised to him is not promised twice.
        (if (none {? offered-to ?applicant})
            (then (begin-belief {?job offered-to ?applicant})))))

    ; THE OFFER LETTER. The form is joined to the promise by the NAME on it - the only
    ; thing the two have in common, and the same key the fusion at the counter uses.
    (try
      (lock-rule)
      (role ?app [k application] (spatial ?app held-by @self)
                                 {@self READ ?app /succ}
                                 -{@self draft-verdict ?app ? /succ})
      (when (and (table-match (attr ?app writing) field applicant value ?name)
                 (substantial (offeree-named ?name))))
      (utility obligation)
      (effects (maintain-proposal {@self draft-verdict ?app [k offer-letter]})))

    ; THE REJECTION. No open post of his kind remains un-offered, so there is nothing to
    ; give him. Nobody is minted: @self answers the paper and never learns who he was.
    (try
      (lock-rule)
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?app [k application] (spatial ?app held-by @self)
                                 {@self READ ?app /succ}
                                 -{@self draft-verdict ?app ? /succ})
      (when (and (table-match (attr ?app writing) field job value ?jk)
                 (table-match (attr ?app writing) field applicant value ?name)
                 (unsubstantial (offeree-named ?name))
                 (unsubstantial (open-job-for ?org ?jk))))
      (utility obligation)
      (effects (maintain-proposal {@self draft-verdict ?app [k rejection-letter]})))

    (try
      (when (empty (spatial @self hold [k application])))
      (effects (set-outcome ?rt-rel /succ)))))
