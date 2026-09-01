; ----------------------------------------------------------------------------
; inheritance - the will-based estate lane (replaces the C++ pick_heir /
; inherit_estate settlement).
;
;   deliberate_will   : once a year an adult re-picks the single heir they wish
;                       to name and (re)writes their will. Heirship is a living
;                       CHOICE recorded in a written document, not an omniscient
;                       death-time kin law.
;   settle_inheritance : when a living NPC learns a KINSMAN has died, they open an
;                       `inherit` task: reach the deceased's home, READ the will
;                       there, and - if it names them heir - claim the estate. A
;                       non-heir kinsman who reads it simply learns nothing to
;                       claim and the task lapses. No death-time cross-mind read:
;                       the heir is discovered by reading the physical will.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

; The preferred heir: a living relative the testator knows, ranked spouse > child
; > sibling (a choice, not a primogeniture age-law - within a tier the select's
; first witness binds one). No candidate -> no proposal -> no will.
(npc-think deliberate_will
  (cooldown 1 m)
  (role @self (adult @self))
  (role ?heir (any_human ?heir)
    {@self spouse|child|sibling ?heir}
    (select (score (+ (* 4 (count (every {@self spouse  ?heir})))
                      (* 2 (count (every {@self child   ?heir})))
                      (count       (every {@self sibling ?heir}))))))
  (when (in-month 12))
  (utility duty)
  (effects (maintain-proposal {@self WRITE-WILL ?heir})))

; Open the settle task on learning a relative died. Any kinsman may attend the
; reading; only the one the will names ends up claiming.
(npc-think settle_inheritance
  (cooldown 1 m)
  (role ?dead (believes {?dead condition [k dead]}))
  (when {@self spouse|child|sibling ?dead})
  (utility duty)
  (effects (begin-proposal {@self receive-inheritance ?dead})))
