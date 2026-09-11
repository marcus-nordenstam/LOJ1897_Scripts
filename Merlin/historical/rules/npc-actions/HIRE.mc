; ----------------------------------------------------------------------------
; HIRE ?worker ?job-kind - the officer signs a man onto the book as a clerk (or a
; bookkeeper, or a porter): THE act by which employment is granted. It is the OFFICER's
; act, not the applicant's, because the post is his to give - the applicant can only
; present himself and be taken on or turned away.
;
; An ACTION is a PHYSICAL PRIMITIVE, so every field is physical, literal or spatial. The
; man is physical and the book is found in the world; the post is handed in as its KIND,
; a literal. A JOB OBJECT may not ride here: no archetype hosts one, so it can never
; cross into the world an onlooker watches, and the act would be refused at the boundary.
; (It used to, which is why HIRE failed twelve times a year and wrote nobody onto any
; book - the ledger's `job` column holds kinds, so an object matched no row either.)
; WHICH LINE he goes on is not the act's to choose beyond `the first vacant one of that
; kind`: the officer's belief about which line that was comes from reading the book.
;
; There is no append - hire-onto-post fills a VACANT line of that kind or does nothing -
; so a man who comes for a post already taken is simply not written down, and the
; establishment never grows past its own book.
; ----------------------------------------------------------------------------

(npc-action {@self HIRE ?worker ?job-kind}:?hire-rel
  (track-skill-level [k personnel])
  (tar human)
  ; [k job] - a job KIND rides here, a literal. `(aux job)` would say an OBJECT of
  ; kind job, which no archetype can host and which a physical act may not touch.
  (aux [k job])
  (duration 15)
  (effects
    (check (spatial ?worker co-located @self))
    ; You cannot write a man onto the book without his NAME - the cell holds one, and a
    ; nameless row names nobody. He gives it when he presents himself.
    (check (substantial (name ?worker)))
    (tolerate (closest [k employee-register]): ?reg)
    (check (substantial ?reg))
    ; Fill a VACANT line of that kind, IN PLACE, and never append: an establishment has the
    ; lines it has, so a man who comes for a post already taken is simply not written down.
    ; (Already on the book for it -> nothing to do; a second signing never duplicates a line.)
    (if (not (table-match (attr ?reg writing) worker (name ?worker) job ?job-kind))
        (then (table-set ?reg (where worker @nothing job ?job-kind)
                              worker (name ?worker) level [k trainee])))
    (set-outcome ?hire-rel /succ)))
