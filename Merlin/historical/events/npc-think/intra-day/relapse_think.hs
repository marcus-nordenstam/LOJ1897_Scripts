; ----------------------------------------------------------------------------
; relapse (B4 pressure model) - the drink pressure of a DEPENDENT drinker (the
; standing {@self craving alcohol} drive). A craving never decays, so a dependent
; relapses OFTEN: the same drink pressure as crave_drink but a far shorter fuse
; and a higher ceiling. Distress (withdrawal) and weak restraint drive it up;
; piety and belonging resist but never to zero - the lifelong battle.
;
; crave_drink excludes the dependent and relapse casts only him, so the two are
; disjoint drivers of the ONE {@self drink} act-goal (one executor, two desires).
; Dependence ONSET is still rolled by drink_act (drink.hs). No aim, no end-goal:
; drinking resets the days-since pressure and relapse quiets until it rebuilds.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think relapse
  (short-term-think)
  (role @self (grown @self))
  ; The nearest pub the NPC KNOWS (role-cast; no known pub -> no fire).
  (role ?pub [k building pub] (select (score (near @self ?pub)) (policy roulette)))
  ; A dependent, a drink already ~due (short fuse - he relapses fast).
  (when (and (= (target {@self craving}) [k alcohol])
             (>= (days-since-last @self drink) 1)))
  ; High pull: distress + weak restraint drive, piety/belonging resist (bounded,
  ; never to zero). Ramps fast, capped high enough to be a near-daily draw but
  ; still short of work / sleep.
  (utility (* (min (* (+ 0.5 (* 0.8 (attr @self withdrawal)))
                      (+ 0.6 (* 0.6 (- 1 (attr @self industriousness))))
                      (- 1.3 (* 0.6 (target {@self piety})))
                      (- 1.3 (* 0.6 (target {@self belonging})))) 1.6)
              (min (* (days-since-last @self drink) 5) 45)))
  (cont-fire-effects
    (if (can-drink @self)
        (begin-goal {@self drink})
        (if (and (is-entity ?pub) (not (= ?pub @self)))
            (go-into ?pub)))))
