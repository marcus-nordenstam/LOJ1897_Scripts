; ----------------------------------------------------------------------------
; record-advert ?reg ?job-id - note on the wage book that the post on line ?job-id is
; advertised: today goes in its `advertise-date` cell. The notice itself hangs on the
; parish board; this is the firm's own record that it was put up, so the officer - or
; whoever takes the duty after him - reads which openings stand advertised off the page
; rather than from memory.
; ----------------------------------------------------------------------------

(action {@self RECORD-ADVERT ?reg ?job-id}:?RECORD-ADVERT
  (motor body legs)
  (track-skill-level [k personnel])
  (tar [k document] @object)
  (duration (seconds 5 min))
  (effects
    (check (spatial @self can-reach ?reg /env))
    (check (table-set ?reg (where job-id ?job-id) advertise-date (time date)))
    (set-outcome ?RECORD-ADVERT /succ)))
