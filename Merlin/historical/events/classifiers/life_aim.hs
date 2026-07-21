; ----------------------------------------------------------------------------
; life_aim (classifier, Shape M). The dominant of the seven aims - an argmax over
; multiplicative composites; the floor keeps a featureless NPC wanting to belong
; somewhere. (mint-argmax) ends the prior dominant on a qualitative shift and marks
; both ends core-episode so the multi-decade interval history survives semantic
; compression.
;
; Reads value dims via the dimensions.hs macros ((piety) / (criminality) /
; (rootedness)), the C++ wealth/decorum floats via (target ...), the situation bands
; + (present ...) via (believes ...), the any-tense worship-at-church act-record via
; a kind-cast /ever believes, and the friend count via (count-beliefs ...). Gated on
; wealth+decorum being derived.
; ----------------------------------------------------------------------------

(npc-think classify_life_aim
  ; Monthly cooldown: the argmax folds (piety) (decaying worship evidence) and (criminality) /
  ; (rootedness) tallies alongside the wealth/decorum floats and situation bands; the decaying
  ; reads never edge the seam, so a periodic recompute is needed to track them. Once-per-window
  ; (gated on wealth+decorum being derived) matches the legacy monthly cadence; self-primed by
  ; cold_start_window.
  (schedule cooldown 1 m)
  (if-blocked hold)
  (rng-stream behaviour)

  (role @self (believes {@self wealth ?})
              (believes {@self decorum ?}))

  (effects
    (mint-argmax {@self life_aim} 0.01 [k life_aim belonging_aim]
      [k life_aim legacy_aim]
        (* (/ (+ (attr @self compassion) (attr @self politeness)) 2)
           (+ 0.3 (* (believes {@self child ?}) 0.7))
           (+ 0.3 (* (clamp (+ (believes {@self class_situation [k class_situation upper]})
                               (believes {@self class_situation [k class_situation middle]})) 0 1) 0.7)))
      [k life_aim wealth_aim]
        (* (attr @self industriousness)
           (- 1 (piety))
           (max (- 1 (target {@self wealth}))
                (believes {@self social_trajectory [k social_trajectory rising]})))
      [k life_aim piety_aim]
        (* (piety)
           (- 1 (criminality))
           (+ 0.4 (* (believes {@self worship [k building church]:?w /ever}) 0.6)))
      [k life_aim respectability_aim]
        (* (attr @self politeness)
           (piety)
           (+ 0.2 (* (believes {@self class_situation [k class_situation middle]}) 0.8))
           (target {@self decorum}))
      [k life_aim autonomy_aim]
        (* (attr @self assertiveness) (- 1 (rootedness)))
      [k life_aim power_aim]
        (* (attr @self machiavellianism)
           (attr @self narcissism)
           (+ 0.3 (* (believes {@self employer ?}) 0.7)))
      [k life_aim belonging_aim]
        (* (attr @self enthusiasm)
           (- 1 (rootedness))
           (clamp (* (count-beliefs @self friend) 0.2) 0 1)))))
