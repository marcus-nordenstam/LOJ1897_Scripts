; ----------------------------------------------------------------------------
; JUDGE-DECLARE ?winner ?sport - the organiser's closing act of the club meet: he declares
; the winner his own judging chose, aloud to the assembled. (obs): co-present racers witness
; it, which is how a losing racer learns the victor (outdone-at-meet,
; thinks/sporting-judge-think.mc). The organiser comes away holding the win; the winner
; learns it the way anyone learns a told state, by being told it.
; ----------------------------------------------------------------------------

(action {@self JUDGE-DECLARE ?winner ?sport}:?JUDGE-DECLARE
  (motor mouth)
  (track-skill-level [k officiating])
  (obs) (duration (seconds 30 min))
  (effects
    (begin-belief {?winner win ?sport})
    (set-outcome ?JUDGE-DECLARE /succ)))
