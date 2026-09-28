; ----------------------------------------------------------------------------
; rest ?venue - a home-leisure day (the amenity-gated default, proposed by household-day
; in household_think.mc). A leisure day has no sub-steps: the promoted task concludes
; immediately, leaving the ended task belief as the episodic memory (the decay pass folds
; repeats into a cumulative-frequency belief).
; ----------------------------------------------------------------------------

(task {@self rest ?venue}:?rest
  (tar [k structure|space] @object)
  (try
    (role @self
      (effects (set-outcome ?rest /succ)))))
