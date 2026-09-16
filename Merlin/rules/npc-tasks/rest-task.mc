; ----------------------------------------------------------------------------
; rest ?venue - a home-leisure day (the amenity-gated default, proposed by household_day
; in household_think.hs). A leisure day has no sub-steps: the promoted task concludes
; immediately, leaving the ended task belief as the episodic memory (the decay pass folds
; repeats into a cumulative-frequency belief).
; ----------------------------------------------------------------------------

(npc-task {@self rest ?venue}:?t-rel
  (tar structure|space)
  (try
    (role @self)
    (effects (set-outcome ?t-rel /succ))))
