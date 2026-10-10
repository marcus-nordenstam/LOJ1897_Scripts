; ----------------------------------------------------------------------------
; strike-advert ?reg ?job-id - the twin of RECORD-ADVERT: the notice has come down, so the
; line's `advertise-date` is cleared.
; ----------------------------------------------------------------------------

(action {@self STRIKE-ADVERT ?reg ?job-id}:?STRIKE-ADVERT
  (motor body legs)
  (track-skill-level [k personnel])
  (tar [k document] @object)
  (duration (seconds 5 min))
  (effects
    (check (spatial @self can-reach ?reg /env))
    (check (table-set ?reg (where job-id ?job-id) advertise-date @nothing))
    (set-outcome ?STRIKE-ADVERT /succ)))
