; ----------------------------------------------------------------------------
; gamble-urge-driver - gambling is a vice, so its pull is addiction-driven, not overdue-driven: a
; man who never gambled feels none. Susceptibility (low industriousness) x an amplifier that
; starts tiny (a rare onset) and spirals with gambling-addiction, x a days-since-last craving
; modulator clamped to [0,1]. The disciplined never gamble; the addicted are pulled in deep.
; He plays at a pub he knows (tasks/gamble-task.mc); no known pub, no gambling.
; ----------------------------------------------------------------------------

; The onset roll is load-bearing: without it every adult would take a first flutter and the
; whole town would spiral into addiction.
(driver gamble-urge-driver
  (cooldown 10 d try-once)
  (role @self {@self gambling-addiction ?gambling-addiction}
              {@self industriousness ?industriousness}
              {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (role ?venue [k pub-building] (select (score (near @self ?venue)) (policy roulette unknown-last))
      (when (and (>= (days-since-last {@self PLAY-GAME /succ /ever}) 10)
                 (or (> ?gambling-addiction 0.0)
                     (latch-eval (chance (* 0.02 (- 1.0 ?industriousness)))))))
      (declare-utility want (* 10.0 (* (- 1.0 ?industriousness)
                  (+ 2.0 (* 22.0 ?gambling-addiction))
                  (min (* (days-since-last-float {@self PLAY-GAME /succ /ever}) 0.04) 1.0))))
      (effects (maintain-proposal {@self gamble ?venue})))))
