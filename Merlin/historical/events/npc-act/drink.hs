; drink - the APPROACH/EXECUTE acts of the drinking lane (npc-act). Desire (crave_drink) is in npc-think/crave_drink.hs.
; (Split from the original lane file in the npc-think/npc-act reorg.)

(hsim-event seek_drink
  (intra-day)
  (when (and (has-goal drink)
             (not (can-drink @self))))
  (utility 30)
  (effects
    (go @self (venue [k building pub]))))

; (c) EXECUTE - hold the goal and at a place with drink (a pub, or home): the
; durative drink act.
(hsim-event drink
  (intra-day)
  (when (and (has-goal drink)
             (can-drink @self)))
  (utility 30)
  (effects
    (act drink_episode 90)))

; The COMPLETION of the drink act (completion-only: never seeded, fired only when the
; act lands a duration later, in the serial completion pass). Applies the real
; effects + clears the goal. Implicit actor: the act's owner is bound as @self.
(hsim-event drink_episode
  (schedule (completion-only))
  (effects
    ; Intoxication accumulates as a lifetime-drinking proxy (v1 - no decay);
    ; the sobriety classifier reads the attr back. Locationless by design: pub
    ; co-presence comes from the itinerary's vice/social routing, so no false
    ; "drank at the Crown" whereabouts is minted here.
    (set-attr @self intoxication (min 1 (+ (attr @self intoxication) 0.34)))
    ; Dependence onset: only an established heavy drinker is at risk, scaled
    ; by temperament - weak restraint (low industriousness) and negative-affect
    ; self-medication (high withdrawal) raise the odds without making it a
    ; destiny. The durable craving drive belief is idempotent at commit.
    (if (and (>= (attr @self intoxication) 0.5)
             (chance (* 0.06
                        (+ 0.4 (* 1.6 (- 1 (attr @self industriousness))))
                        (+ 0.6 (* 0.8 (attr @self withdrawal))))))
        (begin-belief {@self craving [k alcohol]}))
    (end-goal {@self drink})
    ))
