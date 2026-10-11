; ----------------------------------------------------------------------------
; shoot ?victim - a killing means pursue-kill (thinks/hot/kill-think.mc) proposes to a man
; holding a firearm: reach the victim (where he is, else his home) and SHOOT until he is dead.
; The blows (SHOOT) are the (obs) witnessed acts that carry the blame.
; ----------------------------------------------------------------------------


(task {@self shoot ?victim}:?shoot
  (track-skill-level [k marksmanship])
  (tar [k human] @object)
  (construed-act harm-act) (theme violent-to) (contradicts life)
  (facets reportable_crime blackmailable)
  (init (check (not (empty (spatial @self hold [k firearm])))))
  (and
    ; REACH (armed only): route to the victim's known location, else their home.
    (try
      (when (and (not (spatial ?victim co-located @self))
                 (not (empty (spatial @self hold [k firearm])))
                 -{?victim condition [k dead]}
                 (spatial ?victim space)))
      (effects (maintain-proposal {@self go-to ?victim})))
    (try
      (role ?vhome {?victim home ?vhome}
        (when (and (not (spatial ?victim co-located @self))
                   (not (empty (spatial @self hold [k firearm])))
                   -{?victim condition [k dead]}
                   (unknown (spatial ?victim space))))
        (effects (maintain-proposal {@self go-to ?vhome}))))

    ; THE SHOT: armed, co-present with a living victim - fire.
    (try
      (when (and (spatial ?victim co-located @self)
                 (not (empty (spatial @self hold [k firearm])))
                 -{?victim condition [k dead]}))
      (declare-utility always-pick)
      (effects (maintain-proposal {@self SHOOT ?victim})))

    ; CONCLUDE: the victim is dead - the method is spent.
    (try
      (when {?victim condition [k dead]})
      (effects (set-outcome ?shoot /succ)))))
