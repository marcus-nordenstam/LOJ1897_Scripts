; ----------------------------------------------------------------------------
; record-offer ?applicant-name ?job-id - the officer pencils a promise against ONE line of
; the wage book: the line of the seat the man applied for carries his NAME in its
; `offered` cell and today in `offer-date`. The NAME rides, not the man: he is someone the
; officer has only heard of - realis, ungrounded, no entity behind him - and a physical
; act carrying him would be refused at the boundary. A promise is a letter in the post,
; and this is the book's own note of it - who was written to, and when - so a second
; officer reads the same fact. It RESERVES nothing: first through the door is hired (HIRE
; clears the pencil). The book is found in the world, as HIRE finds it.
; ----------------------------------------------------------------------------

(npc-action {@self RECORD-OFFER ?applicant-name ?job-id}:?ro-rel
  (motor body legs)
  (track-skill-level [k personnel])
  (tar ?)
  (aux ?)
  (duration (seconds 5 min))
  (effects
    (check (substantial ?applicant-name))
    (tolerate (closest [k employee-register]): ?reg)
    (check (substantial ?reg))
    (check (spatial ?reg co-located @self /env))
    (check (table-set ?reg (where job-id ?job-id)
                           offered ?applicant-name offer-date (time date)))
    (set-outcome ?ro-rel /succ)))
