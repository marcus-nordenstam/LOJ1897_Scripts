; ----------------------------------------------------------------------------
; HIRE ?worker ?job - the officer signs a man onto the book for ?job: THE act by which
; employment is granted. It is the OFFICER's act, not the applicant's, because the post
; is his to give - the applicant can only present himself and be taken on or turned away.
;
; WHICH post is the task's decision, handed in on the pattern. The act itself only reads
; the WORLD: the book is the nearest one, because you write in the book in front of you.
;
; There is no append - hire-onto-post fills a VACANT line of that kind or does nothing -
; so a man who comes for a post already taken is simply not written down, and the
; establishment never grows past its own book.
; ----------------------------------------------------------------------------

(npc-action {@self HIRE ?worker ?job}:?hire-rel
  (track-skill-level [k personnel])
  (tar human)
  (aux job)
  (duration 15)
  (effects
    (check (spatial ?worker co-located @self))
    (tolerate (closest [k employee-register]): ?reg)
    (check (substantial ?reg))
    ; Fill a VACANT line of that kind, IN PLACE, and never append: an establishment has the
    ; lines it has, so a man who comes for a post already taken is simply not written down.
    ; (Already on the book for it -> nothing to do; a second signing never duplicates a line.)
    (if (not (table-match (attr ?reg writing) worker ?worker job ?job))
        (then (table-set ?reg (where worker @nothing job ?job)
                              worker ?worker level [k trainee])))
    (set-outcome ?hire-rel /succ)))
