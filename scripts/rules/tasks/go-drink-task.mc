; ----------------------------------------------------------------------------
; go-drink - get into a pub and DRINK there. Raised by want-drink and relapse. In a pub
; he drinks; knowing one, he goes to it; knowing none, he searches the town for one, and a
; search that covered the town without finding one fails the outing.
; ----------------------------------------------------------------------------

(define-func go-drink-in-pub ()
  (is-a (spatial @self building) [k building pub]))

(task {@self go-drink}:?go-drink
  (cease (if {@self DRINK /succ /caused_by ?go-drink}
             (then (set-outcome ?go-drink /succ))))
  (and
    (try
      (when (go-drink-in-pub))
      (effects (maintain-proposal {@self DRINK})))
    (try
      (role ?pub [k building pub] (select (score (near @self ?pub)) (policy roulette unknown-last))
        (when (not (go-drink-in-pub)))
        (effects (maintain-proposal {@self go ?pub}))))
    (try
      (role @self -{@self find-building [k building pub] ? /fail}
        (no-role [k building pub])
        (when (not (go-drink-in-pub)))
        (effects (maintain-proposal {@self find-building [k building pub] (current-exterior @self)}))))
    (try
      (role @self {@self find-building [k building pub] ? /fail}
        (no-role [k building pub])
        (effects (set-outcome ?go-drink /fail))))))
