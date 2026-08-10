; ----------------------------------------------------------------------------
; life_aim (classifier, Shape M). The dominant of the seven aims - an argmax over
; multiplicative composites; the floor keeps a featureless NPC wanting to belong
; somewhere. (mint-argmax) ends the prior dominant on a qualitative shift and marks
; both ends core-episode so the multi-decade interval history survives semantic
; compression.
;
; Reads value dims via the dimensions.hs macros ((piety) / (criminality) /
; (rootedness)), the C++ wealth/decorum floats via (any ..).target, the situation bands
; + (present ...) via (believes ...), the any-tense worship-at-church act-record via
; a kind-cast /ever believes, and the friend count via (count (every ..)). Gated on
; wealth+decorum being derived.
; ----------------------------------------------------------------------------

(npc-think classify_life_aim
  ; Monthly cooldown: the argmax folds (piety) (decaying worship evidence) and (criminality) /
  ; (rootedness) tallies alongside the wealth/decorum floats and situation bands; the decaying
  ; reads need a periodic recompute to track. Gated on wealth+decorum being derived; self-primed
  ; by cold_start_window.
  (cooldown 1 m)
  (rng-stream behaviour)

  (role @self (believes {@self wealth ?wealth})
              (believes {@self decorum ?decorum}))

  (effects
    (mint-argmax {@self life_aim} 0.01 [k life_aim belonging_aim]
      [k life_aim legacy_aim]
        (* (/ (+ (attr @self compassion) (attr @self politeness)) 2)
           (+ 0.3 (* (any {@self child ?} (out int)) 0.7))
           (+ 0.3 (* (clamp (+ (any {@self class_situation [k class_situation upper]} (out int))
                               (any {@self class_situation [k class_situation middle]} (out int))) 0 1) 0.7)))
      [k life_aim wealth_aim]
        (* (attr @self industriousness)
           (- 1 (piety))
           (max (- 1 ?wealth)
                (any {@self social_trajectory [k social_trajectory rising]} (out int))))
      [k life_aim piety_aim]
        (* (piety)
           (- 1 (criminality))
           (+ 0.4 (* (any {@self worship [k building church] /ever} (out int)) 0.6)))
      [k life_aim respectability_aim]
        (* (attr @self politeness)
           (piety)
           (+ 0.2 (* (any {@self class_situation [k class_situation middle]} (out int)) 0.8))
           ?decorum)
      [k life_aim autonomy_aim]
        (* (attr @self assertiveness) (- 1 (rootedness)))
      [k life_aim power_aim]
        (* (attr @self machiavellianism)
           (attr @self narcissism)
           (+ 0.3 (* (any {@self job.salary ?} (out int)) 0.7)))
      [k life_aim belonging_aim]
        (* (attr @self enthusiasm)
           (- 1 (rootedness))
           (clamp (* (count (every {@self friend ?})) 0.2) 0 1)))))
