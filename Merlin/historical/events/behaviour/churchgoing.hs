; ----------------------------------------------------------------------------
; The CHURCHGOING lane - the three-stage cascade (4.13.15):
;
;   (a) DESIRE   feel_devout   (sim-window-start) - high politeness (respect for
;       convention) draws an NPC to worship; on a hit it mints {@self goal {@self
;       worship}}.
;   (b) APPROACH seek_church   (intra-day) - holds the goal but is not at a church
;       -> a (go) travel act to the parish church.
;   (c) EXECUTE  attend_church (intra-day) - at a church with the goal -> the
;       durative service; its completion mints the standing `worship` piety belief
;       (about the church they are AT) and clears the goal.
;
; Piety is binary (the F3.5 classifier reads the worship belief); the re-mints are
; idempotent, so a devout NPC re-worships harmlessly.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event feel_devout
  (sim-window-start)
  (rng-stream behaviour)
  (roles
    (role @self (template grown)))
  (when (chance (* 0.0333 (+ 0.5 (attr @self politeness)))))
  (effects
    (goal @self worship)))

(hsim-event seek_church
  (intra-day)
  (nl   "@self sets out for church")
  (when (and (has-goal worship)
             (not (self-at [k building church]))))
  (utility 30)
  (effects
    (go @self (venue [k building church]))))

(hsim-event attend_church
  (intra-day)
  (nl   "@self attends the service")
  (when (and (has-goal worship)
             (self-at [k building church])))
  (utility 30)
  (effects
    (act worship_episode 90)))

(hsim-event worship_episode
  (schedule (chain-only))
  (nl   "@self worships at church")
  (effects
    (go-to-church @self)
    (clear-goal @self worship)
    (log _worship_episode @self)))
