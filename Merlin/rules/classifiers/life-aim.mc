; ----------------------------------------------------------------------------
; life-aim (classifier, Shape M). The dominant of the seven aims - an argmax over
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

  (role @self {@self wealth ?wealth}
              {@self decorum ?decorum})

  (effects
    (mint-argmax {@self life-aim} 0.01 [k life-aim belonging-aim]
      [k life-aim legacy-aim]
        (* (/ (+ (target-or @self compassion 0) (target-or @self politeness 0)) 2)
           (+ 0.3 (* (prob {@self child ?}) 0.7))
           (+ 0.3 (* (clamp (+ (prob {@self class-situation [k class-situation upper]})
                               (prob {@self class-situation [k class-situation middle]})) 0 1) 0.7)))
      [k life-aim wealth-aim]
        (* (target-or @self industriousness 0)
           (- 1 (piety))
           (max (- 1 ?wealth)
                (prob {@self social-trajectory [k social-trajectory rising]})))
      [k life-aim piety-aim]
        (* (piety)
           (- 1 (criminality))
           (+ 0.4 (* (prob {@self WORSHIP [k building church] /ever}) 0.6)))
      [k life-aim respectability-aim]
        (* (target-or @self politeness 0)
           (piety)
           (+ 0.2 (* (prob {@self class-situation [k class-situation middle]}) 0.8))
           ?decorum)
      [k life-aim autonomy-aim]
        (* (target-or @self assertiveness 0) (- 1 (rootedness)))
      [k life-aim power-aim]
        (* (target-or @self machiavellianism 0)
           (target-or @self narcissism 0)
           (+ 0.3 (* (>= (prob {@self job.salary ?}) 1) 0.7)))
      [k life-aim belonging-aim]
        (* (target-or @self enthusiasm 0)
           (- 1 (rootedness))
           (clamp (* (count (every {@self friend ?})) 0.2) 0 1)))))
