; ----------------------------------------------------------------------------
; gamble ?venue - go to the pub and play there (PLAY-GAME).
; ----------------------------------------------------------------------------

(task {@self gamble ?venue}:?gamble
  (tar [k pub-building] @object)
  (and
    (try
      (role @self (not (spatial @self building ?venue))
        (effects (maintain-proposal {@self go-to ?venue}))))
    (try
      (role @self (spatial @self building ?venue)
        (effects (maintain-proposal {@self PLAY-GAME}))))
    (try
      (role @self {@self PLAY-GAME /succ /caused_by ?gamble}
        (effects (set-outcome ?gamble /succ))))))
