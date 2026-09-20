; ----------------------------------------------------------------------------
; enrol ?reg ?job ?level - THE one dumb roster-write: file @self's row (worker @self,
; at ?job / ?level) onto the register ?reg the proposing task resolved (perceived at
; the org's premises). Pen changes paper; WHICH register, and what job / level, are the
; task's decision, handed in on the pattern. EMPLOYMENT only - a club's members go on its
; own roll via JOIN-ROLL. The worker READs his own row back to realize the post; other
; staff are learned by the roster-reading duty (read_roster).
; ----------------------------------------------------------------------------

(npc-action {@self ENROL ?reg ?job}:?en-rel
  (duration (seconds 15 min))
  (effects
    ; The vacant line for this post is what @self fills; a job outside the establishment
    ; (a head's seat) simply adds one. New lines start at the entry rank.
    (fill-post ?reg ?job [k trainee])
    (set-outcome ?en-rel /succ)))
