; ----------------------------------------------------------------------------
; go-drink - a session in the bar-room of a pub: a few drinks, one an hour (pubbing.ms2, with the
; bar's glasses standing full in place of a bartender's service). With his hand free he takes a
; full glass - the drink he is drawn to most likely - and drinks it; an empty glass he sets down.
; Raised by want-drink and relapse. It requires that he stands in a bar-room for as long as it runs
; (stands-in-room-of), which enter-room-kind achieves before go-drink is proposed and again
; whenever something takes him out; a pub he cannot get into holds it out with the outing.
; ----------------------------------------------------------------------------

; How many drinks a session runs to, and the minutes between one and the next.
(define-macro session-drinks () 3)
(define-macro drink-interval-minutes () 60)

; Where he stands to take ?glass off the bar, once ?glass is his: @fail while another holds it.
(define-func claimed-stand-by (?glass)
  (if (claim ?glass) (then (claim (stand-spot-by ?glass))) (else @fail)))

(task {@self go-drink}:?go-drink
  (running-requirements (stands-in-room-of [k bar-room] [k pub-building]))
  (cease (if (and (>= (session-drink-count ?go-drink) (session-drinks))
                  (unsubstantial (held-glass @self)))
             (then (set-outcome ?go-drink /succ))))
  ; Ending with a glass in hand, he sets it down before anything else takes him.
  (closing
    (sequence
      (stage
        (effects
          (bind (held-glass @self) ?glass)
          (if (substantial ?glass)
              (then (maintain-proposal {@self put ?glass (spatial @self space)})))))
      (stage
        (effects (done-closing ?go-drink)))))
  (and
    ; A full glass in hand: drink it.
    (try
      (role ?fluid [k fluid] (= (drinker-of ?fluid) @self)
        (effects (maintain-proposal {@self DRINK ?fluid}))))
    ; An empty glass in hand: set it down.
    (try
      (role ?glass [k drinking-glass] (= (spatial ?glass held-by) @self)
        (when (unsubstantial (glass-drink ?glass)))
        (effects (maintain-proposal {@self put ?glass (spatial @self space)}))))
    ; Hand free, the session not done and the hour since the last drink gone: fetch a full
    ; glass off the bar, the drink he is drawn to most likely.
    (sequence
      (when (unsubstantial (held-glass @self)))
      (when (< (session-drink-count ?go-drink) (session-drinks)))
      (when (>= (minutes-since-session-drink ?go-drink) (drink-interval-minutes)))
      (stage
        (role ?glass [k drinking-glass] (spatial ?glass space (spatial @self space))
                                        (unsubstantial (spatial ?glass gripped-by))
                                        (claimable ?glass)
                                        (substantial (glass-drink ?glass))
                                        (select (score (drink-appeal (kind (glass-drink ?glass))))
                                                (policy roulette)))
        (when (claimed-stand-by ?glass): ?spot)
        (effects (maintain-proposal {@self go-to ?spot})))
      (stage
        (effects (maintain-proposal {@self take ?glass}))))
    ; STAY: he keeps to the bar-room while he is at it; nothing below his outing's band walks him out.
    (try (declare-utility fallback)
         (effects (maintain-proposal {@self DWELL (spatial @self space) (+ (time hour) 1)})))))
