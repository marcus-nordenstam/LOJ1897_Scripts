; ----------------------------------------------------------------------------
; go-drink - get into the bar-room of a pub and DRINK there. Raised by want-drink and
; relapse. In a bar-room he drinks; in a pub he goes to its bar-room, locating one he does
; not know; a pub he finds no bar-room in fails the outing, as does a town search that finds
; no pub.
; ----------------------------------------------------------------------------

(task {@self go-drink}:?go-drink
  (cease (if {@self DRINK /succ /caused_by ?go-drink}
             (then (set-outcome ?go-drink /succ))))
  (and
    (try
      (when (stands-in-room [k bar-room]))
      (effects (maintain-proposal {@self DRINK})))
    (try
      (role ?pub [k pub-building] (spatial @self building ?pub)
        (role ?bar-room [k bar-room] (spatial ?bar-room building ?pub)
                                     (select (score (near @self ?bar-room)) (policy roulette unknown-last))
          (when (not (stands-in-room [k bar-room])))
          (effects (maintain-proposal {@self go ?bar-room})))))
    (try
      (role ?pub [k pub-building] (spatial @self building ?pub)
        (role @self -{@self locate [k bar-room] ?pub /fail}
          (when (not (stands-in-room [k bar-room]))
                (not (spatial ?pub room [k bar-room])))
          (effects (maintain-proposal {@self locate [k bar-room] ?pub})))))
    (try
      (role ?pub [k pub-building] (spatial @self building ?pub)
        (role @self {@self locate [k bar-room] ?pub /fail}
          (effects (set-outcome ?go-drink /fail)))))
    (try
      (role ?pub [k pub-building] (select (score (near @self ?pub)) (policy roulette unknown-last))
        (when (not (stands-in-building [k pub-building])))
        (effects (maintain-proposal {@self go ?pub}))))
    (try
      (role @self -{@self find-building [k pub-building] ? /fail}
        (no-role [k pub-building])
        (when (not (stands-in-building [k pub-building])))
        (effects (maintain-proposal {@self find-building [k pub-building] (current-exterior @self)}))))
    (try
      (role @self {@self find-building [k pub-building] ? /fail}
        (no-role [k pub-building])
        (effects (set-outcome ?go-drink /fail))))))
