; ----------------------------------------------------------------------------
; christen (action) - @self names ?child: its father's surname, and a first name for its gender
; from the names of that surname's nationality that nobody in the world holds with it yet. The
; name is the child's (an attr); what @self comes to believe of it is the proposing task's,
; which reads it off this act's `name`.
; ----------------------------------------------------------------------------

(action {@self CHRISTEN ?child ?father}:?CHRISTEN
  (motor mouth)
  (duration 10)
  (effects
    (check (unsubstantial (attr ?child name)))
    (sample-name (attr ?child gender) (attr ?father name)): ?name
    (check (substantial ?name))
    (set-attr ?child name ?name)
    (bb-write ?CHRISTEN name ?name)
    (set-outcome ?CHRISTEN /succ)))
