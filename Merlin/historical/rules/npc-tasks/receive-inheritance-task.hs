; ----------------------------------------------------------------------------
; inherit (npc-task) - a kinsman settles a deceased relative's estate by the will.
;
; Proposed by settle_inheritance when @self learns a relative ?dead has died.
; @self routes to the deceased's home, READs the will kept there (adopting its
; bequest), and - if the will names @self heir (so @self now holds {@self inherit
; ?pile}) - claims the estate (INHERIT). A kinsman the will does NOT name reads it,
; learns nothing to inherit, and the task abandons. Heir discovery is the physical
; act of reading the will; no death-time cross-mind kin walk.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-task {@self receive_inheritance ?dead}:?inherit-rel
  (tar human)
  (role ?dhome {?dead home ?dhome})
  (role ?will [k will] (spatial ?will building ?dhome))
  (and
    ; REACH the deceased's home, where the will is kept.
    (try
      (when (not (spatial @self building ?dhome)))
      (utility duty)
      (effects (maintain-proposal {@self go ?dhome})))

    ; READ the will (co-present with it) - adopt its bequest into @self's mind.
    (try
      (when (and (spatial @self building ?dhome)
                 (none {@self inherit ?})
                 (none {@self READ ?will /succ})))
      (utility duty)
      (effects (maintain-proposal {@self READ ?will})))

    ; CLAIM: the will named @self - a bequest belief was adopted - so effect it.
    (try
      (when (any {@self inherit ?pile}))
      (utility duty always-pick)
      (effects (maintain-proposal {@self INHERIT ?dead ?pile})))

    ; CONCLUDE: the estate was claimed.
    (try
      (when (any {@self INHERIT ?dead ? /succ}))
      (effects (set-outcome ?inherit-rel /succ)))

    ; ABANDON: the will was read but named someone else (nothing to inherit).
    (try
      (when (and (any {@self READ ?will /succ})
                 (none {@self inherit ?})))
      (effects (set-outcome ?inherit-rel /fail)))))
