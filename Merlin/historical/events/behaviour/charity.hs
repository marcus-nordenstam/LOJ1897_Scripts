; ----------------------------------------------------------------------------
; The CHARITY lane - the three-stage cascade (4.13.15):
;
;   (a) DESIRE   feel_charitable (sim-window-start) - high compassion moves an NPC
;       to give alms; on a hit it mints {@self goal {@self give}}.
;   (b) APPROACH seek_alms_church (intra-day) - holds the goal but is not at a
;       church -> a (go) travel act to the parish church (the Victorian charity
;       venue).
;   (c) EXECUTE  give_alms_act (intra-day) - at a church with the goal -> the
;       durative almsgiving; its completion mints the {@self give <sum>} act-record
;       (read by the F3.5 generosity classifier) and clears the goal.
;
; The old once-per-giver gate ({@self give ? ?}) is dropped: a compassionate NPC
; gives repeatedly, and the recurrence is the generosity signal.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event feel_charitable
  (sim-window-start)
  (rng-stream behaviour)
  (roles
    (role @self (template grown)))
  (when (chance (* 0.00067 (+ 0.4 (* 1.2 (attr @self compassion))))))
  (effects
    (goal @self give_alms)))

(hsim-event seek_alms_church
  (intra-day)
  (nl   "@self sets out to give alms")
  (when (and (has-goal give_alms)
             (not (self-at [k building church]))))
  (utility 30)
  (effects
    (go @self (venue [k building church]))))

(hsim-event give_alms_act
  (intra-day)
  (nl   "@self gives alms")
  (when (and (has-goal give_alms)
             (self-at [k building church])))
  (utility 30)
  (effects
    (act alms_episode 60)))

(hsim-event alms_episode
  (schedule (chain-only))
  (nl   "@self gives alms at the church")
  (effects
    (give-alms @self)
    (clear-goal @self give_alms)
    (log _alms_episode @self)))
