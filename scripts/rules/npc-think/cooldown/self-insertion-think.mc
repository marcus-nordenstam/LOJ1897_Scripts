; ----------------------------------------------------------------------------
; self_insertion - the narcissistic killer inserts himself into the mystery his own
; crime made: he denounces an innocent to the police by letter, under an alias. He
; wants the attention, not the rope, so the letter is not in his name - but it is in
; his hand.
;
; The innocent is drawn once, when the denunciation starts; while it runs, the first
; branch keeps proposing it with the same innocent.
; ----------------------------------------------------------------------------

(npc-think self_insertion
  (cooldown 1 m try-once)
  (rng-stream perpetration)
  (role @self {@self age-band [k young-adult|middle-aged|mature|elderly]}
    ; His own overt-method kill: the corpse whose mystery he inserts himself into.
    (role ?victim {@self strangle|shoot ?victim /succ /ever}
                  (not (alive ?victim))
      (utility want)
      (stable-or
        (try
          (role ?innocent {@self denounce ?innocent ?victim}
            (effects (maintain-proposal {@self denounce ?innocent ?victim}))))
        (try
          (role ?innocent {?innocent isa [k human], condition [k alive]}
                          (select (score 1) (policy roulette))
            (when (and (!= ?innocent ?victim)
                       (!= ?innocent @self)
                       -{@self denounce ? ?victim /ever}
                       (>= (target-or @self narcissism 0.0) 0.7)
                       (chance 0.04)))
            (effects (maintain-proposal {@self denounce ?innocent ?victim}))))))))
