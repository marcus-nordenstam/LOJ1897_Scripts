; ----------------------------------------------------------------------------
; relapse (B4 pressure model) - the drink pressure of a DEPENDENT drinker (the
; standing {@self craving alcohol} drive). A craving never decays, so a dependent
; relapses OFTEN: the same drink pressure as crave_drink but a far shorter fuse
; and a higher ceiling. Distress (withdrawal) and weak restraint drive it up;
; piety and belonging resist but never to zero - the lifelong battle.
;
; crave_drink excludes the dependent and relapse casts only him, so the two are
; disjoint drivers of the ONE {@self DRINK} act-goal (one executor, two desires).
; Dependence ONSET is still rolled by drink_act (drink.hs). A maintenance drive: it
; holds {@self DRINK} while due and ends its OWN source (cease-effects) when drinking
; resets the days-since pressure - want_drink owns its source symmetrically, so under
; multi-rule support each of the two co-minters withdraws only its own hold.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think relapse
  ; The dependent's short-fuse drink drive - a 1-day cooldown; co-mints the {@self DRINK} goal
  ; with want_drink (each source ceases its own hold when its pressure lapses), and drink_go/find
  ; route to a pub. The routing lane handles movement, and this desire just holds the drink goal.
  (cooldown 1 d)
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
              {@self craving [k alcohol]})   ; the dependency - cached
  ; The nearest pub the NPC KNOWS (role-cast; no known pub -> no fire).
  (role ?pub [k building pub] (select (score (near @self ?pub)) (policy roulette)))
  ; A dependent, a drink already ~due (short fuse - he relapses fast).
  (when (>= (days-since-last {@self DRINK /ever}) 1))
  ; High pull: distress + weak restraint drive, piety/belonging resist (bounded,
  ; never to zero). Ramps fast, capped high enough to be a near-daily draw but
  ; still short of work / sleep.
  ; BAND = the identity/drive escalation: the dependent's baseline relapse rides NEED (a
  ; physiological drive at ordinary strength), escalating to CRISIS at the withdrawal redline
  ; (withdrawal is a DRIVE, not a trait, so the inline threshold is a legitimate escalation).
  (utility (if (>= (attr @self withdrawal) 0.7) (then crisis) (else need))
           (* 10 (* (min (* (+ 0.5 (* 0.8 (attr @self withdrawal)))
                      (+ 0.6 (* 0.6 (- 1 (attr @self industriousness))))
                      (- 1.3 (* 0.6 (piety)))
                      (- 1.3 (* 0.6 (belonging)))) 1.6)
              (min (* (days-since-last {@self DRINK /ever}) 5) 45))))
  (effects       (begin-goal {@self DRINK}))
  (cease-effects (set-outcome {@self goal {@self DRINK}} /succ)))
