; ----------------------------------------------------------------------------
; gamble-urge-driver - gambling is a vice: a man takes his first flutter only when he is bored,
; and gambling-addiction draws him back whether he is or not. Susceptibility (low
; industriousness) x an amplifier that spirals with the addiction x a days-since-last craving
; modulator clamped to [0,1]. He plays at a pub he knows (tasks/gamble-task.mc); no known pub,
; no gambling.
; ----------------------------------------------------------------------------

(define-func gamble-urge-value (?industriousness ?gambling-addiction)
  (* 10.0 (* (- 1.0 ?industriousness)
             (+ 2.0 (* 22.0 ?gambling-addiction))
             (min (* (days-since-last-float {@self PLAY-GAME /succ /ever}) 0.04) 1.0))))

(driver gamble-urge-driver
  (cooldown 10 d try-once)
  (belief {@self gambling-addiction ?gambling-addiction}
              {@self industriousness ?industriousness}
              {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (role ?venue [k pub-building] (select (score (near @self ?venue)) (policy roulette unknown-last))
      (when (and (>= (days-since-last {@self PLAY-GAME /succ /ever}) 10)
                 (> ?gambling-addiction 0.0)))
      (declare-utility want (gamble-urge-value ?industriousness ?gambling-addiction))
      (effects (maintain-proposal {@self gamble ?venue})))))

(driver bored-gamble-driver
  (cooldown 10 d try-once)
  (belief {@self stimulation [k bored|restless]}
              {@self gambling-addiction ?gambling-addiction}
              {@self industriousness ?industriousness}
              {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (role ?venue [k pub-building] (select (score (near @self ?venue)) (policy roulette unknown-last))
      (when (>= (days-since-last {@self PLAY-GAME /succ /ever}) 10))
      (declare-utility want (gamble-urge-value ?industriousness ?gambling-addiction))
      (effects (maintain-proposal {@self gamble ?venue})))))
