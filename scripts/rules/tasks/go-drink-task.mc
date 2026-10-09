; ----------------------------------------------------------------------------
; go-drink - get into the bar-room of a pub and DRINK there. Raised by want-drink and
; relapse. In a bar-room he drinks; getting there is locate-room's, and an outing locate-room
; fails is failed.
; ----------------------------------------------------------------------------

(task {@self go-drink}:?go-drink
  (cease (if {@self DRINK /succ /caused_by ?go-drink}
             (then (set-outcome ?go-drink /succ))))
  (preemptive-or
    (try (role @self (stands-in-room [k bar-room])
           (effects (maintain-proposal {@self DRINK}))))
    (try (role @self {@self locate-room [k pub-building] [k bar-room] /fail /caused_by ?go-drink}
           (effects (set-outcome ?go-drink /fail))))
    (try (when @true)
         (effects (maintain-proposal {@self locate-room [k pub-building] [k bar-room]})))))
