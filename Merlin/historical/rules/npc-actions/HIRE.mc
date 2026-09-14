; ----------------------------------------------------------------------------
; HIRE ?worker ?job-id - the officer signs the man standing in front of the book onto
; ONE line of it: the vacant line the officer chose by its job-id, the way RECORD-ADVERT
; and STRIKE-ADVERT name a line. The line carries the job kind, so nothing else rides; a
; man is written by NAME, which he gives when he presents himself. Signing spends whatever
; promise stood against the line. The line being vacant is the proposer's precondition:
; the officer read it off this book, and only he writes it.
; ----------------------------------------------------------------------------

(npc-action {@self HIRE ?worker ?job-id}:?hire-rel
  (track-skill-level [k personnel])
  (tar human)
  (duration 15)
  (effects
    (check (spatial ?worker co-located @self))
    (check (substantial (name ?worker)))
    (tolerate (closest [k employee-register]): ?reg)
    (check (substantial ?reg))
    (check (spatial ?reg co-located @self /env))
    (check (table-set ?reg (where job-id ?job-id worker @nothing)
                           worker (name ?worker) level [k trainee]
                           hiring-date (date-now)
                           offered @nothing offer-date @nothing))
    (set-outcome ?hire-rel /succ)))
