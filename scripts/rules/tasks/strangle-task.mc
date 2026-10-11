; ----------------------------------------------------------------------------
; strangle ?victim - a killing means pursue-kill (drivers/kill-driver.mc) proposes to a
; strong hand: reach the victim, then STRANGLE until he is dead. The blows are the (obs)
; witnessed violent acts that carry the blame. Concludes on the victim's death, this hand's
; or another's.
; ----------------------------------------------------------------------------


(task {@self strangle ?victim}:?strangle
  (track-skill-level [k garrotting])
  (tar [k human] @object)
  (construed-act harm-act) (theme violent-to) (contradicts life)
  (facets reportable_crime blackmailable)
  (and
    ; REACH: route to the victim's known location, else their home.
    (try
      (when (and (not (spatial ?victim co-located @self))
                 -{?victim condition [k dead]}
                 (spatial ?victim space)))
      (effects (maintain-proposal {@self go-to ?victim})))
    (try
      (role ?vhome {?victim home ?vhome}
        (when (and (not (spatial ?victim co-located @self))
                   -{?victim condition [k dead]}
                   (unknown (spatial ?victim space))))
        (effects (maintain-proposal {@self go-to ?vhome}))))

    ; THE BLOW: co-present with a living victim - CHOKE the life out of them.
    (try
      (when (and (spatial ?victim co-located @self)
                 -{?victim condition [k dead]}))
      (declare-utility always-pick)
      (effects (maintain-proposal {@self STRANGLE ?victim})))

    ; CONCLUDE: the victim is dead - the method is spent.
    (try
      (when {?victim condition [k dead]})
      (effects (set-outcome ?strangle /succ)))))
