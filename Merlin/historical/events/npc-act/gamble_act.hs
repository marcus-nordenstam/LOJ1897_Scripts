; gamble - the gambling ACT-BODY (npc-act). The pressure think that proposes it is
; npc-think/gamble_urge.hs. The {@self play_game <pub>} act-belief - begun at commit,
; ended by (end-act) at completion - IS the episodic memory days-since-last reads.
; No aim, no end-goal.

(npc-act gamble_act
  (when (believes {@self play_game ?venue}))
  (duration 90)
  (act-effects
    ; gambling_addiction is the standing DISPOSITION (a state) - and the amplifier
    ; gamble_urge feeds back into: accumulating ~0.5 per fire (~2 to morbid), it
    ; deepens the pull. The sobriety + wealth classifiers read it graded.
    (set-attr @self gambling_addiction
              (min 1 (+ (attr @self gambling_addiction) 0.5)))
    (end-act {@self play_game ?venue})))
