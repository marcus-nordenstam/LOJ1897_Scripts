; WALK - isim locomotion action. Ontology twin of interactive/actions/WALK.act:
; motor + transmission live here (the ontology), the engine anim / timing / movement
; fields stay in the .act. Minting this term makes {@self WALK ?dest} commit.
(npc-action {@self WALK ?dest}
  (motor legs)
  (obs)
  (duration 0)
  (effects
    (set-outcome {@self WALK ?dest} /succ)))
