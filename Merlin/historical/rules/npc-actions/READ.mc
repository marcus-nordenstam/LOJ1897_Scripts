; ----------------------------------------------------------------------------
; read - THE one document-reading action: take a document's writing into @self's mind.
; Works for ANY document - a letter, a will, a listing, a deed, a register. Getting the
; document into reach, and putting it down / re-filing it afterwards, are the consuming
; task's job (via get / DROP / stack-browse), never bundled in here.
;
; TWO kinds of writing. SENTENCES (a letter, a will) adopt through the writing codec -
; the sanctioned cross-mind write-through-paper, the written twin of hearing speech:
; @self comes away holding whatever the page asserts. A FORM (a table) asserts nothing
; by itself; what its cells MEAN is content, so READ branches on the document's kind
; and reasons the beliefs out here. A job-posting reads as a VACANCY at a named org:
; {?job filled-by _}, "that job is held by nobody" - the same fact @self would hold had
; someone told him "companies house has a clerk's place going" - and the org's door,
; the apply-at cell resolving to a place he imagines off its address until he walks in.
; The org is known by name (imagined until met); the job is imagined outright, a kind
; at an org, no ledger line - a reader never sees the book.
; ----------------------------------------------------------------------------

(npc-action {@self READ ?doc}
  (track-skill-level [k literacy])
  (duration 10)
  (effects
    ; A VERDICT letter answers ONE application, and it names which: kind + org. The offer
    ; is minted as a state of the SEAT - {?job offered-to @self}, the seeker's side of the
    ; line the officer pencilled - so accepting can gate on holding an offer for THAT post.
    ; A rejection ends his vacancy belief instead: that place is not going, to him.
    (if (or (is-a ?doc [k offer-letter]) (is-a ?doc [k rejection-letter]))
        (then
          (tolerate (attr ?doc writing): ?vform)
          (tolerate (table-match ?vform field job-kind value ?vjk))
          (tolerate (table-match ?vform field org-name value ?vorg-name))
          (if (and (substantial ?vjk) (substantial ?vorg-name))
              (then
                (o [k org] {@o name ?vorg-name}): ?vorg
                (o ?vjk {@o org ?vorg}): ?vjob
                (if -{?vjob org ?vorg} (then (begin-belief {?vjob org ?vorg})))
                (if (is-a ?doc [k offer-letter])
                    (then (if -{?vjob offered-to @self}
                              (then (begin-belief {?vjob offered-to @self}))))
                    (else (for-each ?vrel (every {?vjob filled-by _})
                            (end-belief ?vrel))))))))
    (if (is-a ?doc [k job-posting])
        (then
          (tolerate (attr ?doc writing): ?form)
          (tolerate (table-match ?form field job-kind value ?jk))
          (tolerate (table-match ?form field org-name value ?org-name))
          (tolerate (table-match ?form field apply-at value ?apply-at))
          (if (and (substantial ?jk) (substantial ?org-name) (substantial ?apply-at))
              (then
                (o [k org] {@o name ?org-name}): ?org
                (o ?jk {@o org ?org}): ?job
                (if -{?job org ?org}    (then (begin-belief {?job org ?org})))
                (if -{?job filled-by _} (then (begin-belief {?job filled-by _})))
                (if -{?org workplace ?} (then (begin-belief {?org workplace ?apply-at}))))))
        (else (adopt-msg (attr ?doc writing))))
    (set-outcome {@self READ ?doc} /succ)))
