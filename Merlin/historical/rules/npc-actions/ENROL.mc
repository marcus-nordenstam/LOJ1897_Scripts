; ----------------------------------------------------------------------------
; enrol ?reg ?job ?level - THE one dumb roster-write: file @self's row (worker @self,
; at ?job / ?level) onto the register ?reg the proposing task resolved (perceived at
; the org's premises). Pen changes paper; WHICH register, and what job / level, are the
; task's decision, handed in on the pattern. Shared by employment (take-up-post) and
; membership (club join). The worker READs his own row back to realize the post; other
; members are learned by the roster-reading duty (read_roster).
; ----------------------------------------------------------------------------

(npc-action {@self ENROL ?reg ?job}:?en-rel
  (duration 15)
  (effects
    ; New rows start at the entry rank (trainee for a hire; unread for a club member).
    (table-add ?reg worker @self job ?job level [k trainee])
    (set-outcome ?en-rel /succ)))
