; RUN - isim locomotion action. Ontology twin of interactive/actions/RUN.act:
; motor + transmission live here (the ontology), the engine anim / timing / movement
; fields stay in the .act. Minting this term makes {@self RUN ?dest} commit.
(npc-action {@self RUN ?dest}
  (motor legs)
  (obs)
  (duration 0)
  (effects
    (set-outcome {@self RUN ?dest} /succ)))
