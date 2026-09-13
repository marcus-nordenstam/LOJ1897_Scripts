; ----------------------------------------------------------------------------
; strike-advert ?reg ?job-id - the twin of RECORD-ADVERT: the notice has come down, so the
; line's `advertise-date` is cleared.
; ----------------------------------------------------------------------------

(npc-action {@self STRIKE-ADVERT ?reg ?job-id}:?sa-rel
  (track-skill-level [k personnel])
  (tar document)
  (duration 5)
  (effects
    (check (spatial ?reg co-located @self /env))
    (check (table-set ?reg (where job-id ?job-id) advertise-date @nothing))
    (set-outcome ?sa-rel /succ)))
