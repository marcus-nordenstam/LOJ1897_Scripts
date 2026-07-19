; ----------------------------------------------------------------------------
; respectability_situation (classifier). The TRUE-character fuse: the mean of the
; seven conduct dimensions with RAW sobriety and TRUE chastity (what is true of the
; conduct, not what the parish can see - the functioning alcoholic reads low here
; while his repute stays high; the gap is the blackmail stake).
;
; Reads the conduct dims via the dimensions.hs macros ((honesty) / (sobriety) /
; (piety) / (diligence) / (generosity)) and the C++ float dims chastity / decorum
; via (target ...). Gated on chastity + decorum being derived (the only inputs that
; can be absent pre-derive - the value folds always evaluate).
; ----------------------------------------------------------------------------

(npc-think classify_respectability_situation
  (sim-window-think)
  (rng-stream behaviour)

  (role @self (believes {@self chastity ?})
              (believes {@self decorum ?}))

  (cont-fire-effects
    (mint-band {@self respectability_situation}
      (/ (+ (honesty)
            (sobriety)
            (piety)
            (diligence)
            (target {@self chastity})
            (target {@self decorum})
            (generosity)) 7)
      [k respectability_situation exemplary]    0.80
      [k respectability_situation respectable]  0.60
      [k respectability_situation questionable] 0.40
      [k respectability_situation disreputable] 0.20
      [k respectability_situation scandalous]   -1)))
