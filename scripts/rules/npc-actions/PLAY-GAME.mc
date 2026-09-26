; gamble - the gambling ACT-BODY (npc-action). The pressure think that proposes it is
; npc-think/intra-day/gamble_urge_think.mc. The {@self PLAY-GAME} act-belief - begun at
; commit, ended by (set-outcome {..} /succ) at completion - IS the episodic memory days-since-last reads.
; The drive is an abstract {@self PLAY-GAME} goal (gamble_go routes to a pub); the act only
; accrues the addiction disposition and ends its OWN act-belief, never the goal, like drink_action.

(npc-action {@self PLAY-GAME}
  (motor body legs)
  (track-skill-level [k gaming])
  (duration (seconds 90 min))
  (kind_fold)          
  (effects
    ; gambling-addiction is the standing DISPOSITION (a state) - and the amplifier
    ; gamble_urge feeds back into: accumulating ~0.5 per fire (~2 to morbid), it
    ; deepens the pull. The sobriety + wealth classifiers read it graded.
    (set-attr @self gambling-addiction
              (min 1.0 (+ (attr @self gambling-addiction) 0.5)))
    (set-outcome {@self PLAY-GAME} /succ)))
