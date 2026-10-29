; ----------------------------------------------------------------------------
; inheritance - the will-based estate chain (replaces the C++ pick_heir /
; inherit_estate settlement).
;
;   deliberate-will   : once a year an adult re-picks the single heir they wish
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


; The year's end is when he sees to it.
(driver deliberate-will-driver
  (cooldown 1 m try-until-succ)
  (role ?heir {@self duty-to ?heir write-will}
    (when (in-month 12))
    (declare-utility duty)
    (effects (maintain-proposal {@self write-will ?heir}))))

; Open the settle task on learning a relative died. Any kinsman may attend the
; reading; only the one the will names ends up claiming.
; DORMANT - this lane never ran; revived on the form deeds / articles with its own gauntlet.
;(think settle_inheritance
;  (cooldown 1 m try-until-succ)
;  (role ?dead {?dead condition [k dead]}
;              -{@self receive-inheritance ?dead /succ}
;    (when {@self spouse|child|sibling ?dead})
;    (declare-utility duty)
;    (effects (maintain-proposal {@self receive-inheritance ?dead}))))
