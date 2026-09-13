; ----------------------------------------------------------------------------
; record-offer ?applicant-name ?job-kind - the officer pencils a promise against a line of
; the wage book: the first vacant line of that kind carries the applicant's NAME in its
; `offered` cell and today in `offer-date`. The NAME rides, not the man: he is someone the
; officer has only heard of - realis, ungrounded, no entity behind him - and a physical
; act carrying him would be refused at the boundary (measured: /fail in the start cycle,
; body never run). A name is a literal, and a name is all the page can hold anyway. A promise is a letter in the post, and this is
; the book's own note of it - who was written to, and when - so a second officer reads
; the same fact and the counter can tell a man who was promised a post from a stranger.
; It RESERVES nothing: first through the door is hired (HIRE clears the pencil). The book
; is found in the world, as HIRE finds it; the post is handed in as its KIND, a literal.
; ----------------------------------------------------------------------------

(npc-action {@self RECORD-OFFER ?applicant-name ?job-kind}:?ro-rel
  (track-skill-level [k personnel])
  (tar ?)
  (aux [k job])
  (duration 5)
  (effects
    (check (substantial ?applicant-name))
    (tolerate (closest [k employee-register]): ?reg)
    (check (substantial ?reg))
    (check (spatial ?reg co-located @self /env))
    (if (not (table-set ?reg (where worker @nothing job ?job-kind offered @nothing)
                             offered ?applicant-name offer-date (date-now)))
        (then (table-set ?reg (where worker @nothing job ?job-kind)
                              offered ?applicant-name offer-date (date-now))))
    (set-outcome ?ro-rel /succ)))
