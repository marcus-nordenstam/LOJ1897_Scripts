; ----------------------------------------------------------------------------
; go-drink - DRINK in the bar-room of a pub. Raised by want-drink and relapse. It requires that he
; stands in one for as long as it runs (stands-in-room-of), which enter-room-kind achieves before
; go-drink is proposed and again whenever something takes him out; a pub he cannot get into holds
; it out with the outing.
; ----------------------------------------------------------------------------

(task {@self go-drink}:?go-drink
  (running-requirements (stands-in-room-of [k bar-room] [k pub-building]))
  (cease (if {@self DRINK /succ /caused_by ?go-drink}
             (then (set-outcome ?go-drink /succ))))
  (and
    ; A drink off the bar, the one he is drawn to most likely.
    (try
      (role ?drink [k pile] {?drink content-kind ?drink-kind}
                   (is-a ?drink-kind [k fluid])
                   (= (spatial ?drink space) (spatial @self space))
                   (select (score (drink-appeal ?drink-kind)) (policy roulette))
        (effects (maintain-proposal {@self DRINK ?drink}))))
    ; STAY: he keeps to the bar-room while he is at it; nothing below his outing's band walks him out.
    (try (declare-utility fallback)
         (effects (maintain-proposal {@self DWELL (spatial @self space) (+ (time hour) 1)})))))
