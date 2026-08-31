; ----------------------------------------------------------------------------
; seed_coins (npc-action) - EXECUTION half of coin-pile seeding (the deliberation
; is seed_coin_pile in npc-think/hot/money_think.hs). Creates the NPC's coin pile
; in the home kitchen (a guaranteed room) with a zero count - savings accrue into
; it - and records the ownership. One pile per NPC: the belief-guard on the think
; means this runs once. Env writes live here, since a think must not mutate the world.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-action {@self SEED_COINS ?home}
  (duration 0)
  (effects
    (bind 0 ?made)
    (for-each ?room (spatial ?home parts [k interior-space room] /env)
      (if (= ?made 0)
          (then
            (create-entity [k pile] ?room): ?pile
            (set-attr ?pile content-kind [k coin])
            (set-attr ?pile count 0)
            ; SEE it before believing about it - a belief field lands in the believer's own
            ; realm, so an unobserved object reads @fail.
            (observe ?pile)
            (begin-belief {@self own ?pile})
            (begin-belief {@self coin-pile ?pile})
            (bind 1 ?made))))
    (set-outcome {@self SEED_COINS ?home} /succ)))
