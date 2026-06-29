; ----------------------------------------------------------------------------
; The CHURCHGOING lane - the three-stage intra-day lane (4.13.15):
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
    (begin-goal {@self worship})))

