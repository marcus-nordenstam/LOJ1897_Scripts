; ----------------------------------------------------------------------------
; gamble ?venue - go to the pub and play there (PLAY-GAME).
; ----------------------------------------------------------------------------

(task {@self gamble ?venue}:?gamble
  (tar [k pub-building] @object)
  (and
    (try
      (belief (not (spatial @self building ?venue))
        (effects (maintain-proposal {@self enter-building ?venue}))))
    (try
      (belief (spatial @self building ?venue)
        (effects (maintain-proposal {@self PLAY-GAME}))))
    (try
      (belief {@self PLAY-GAME /succ /caused_by ?gamble}
        (effects (set-outcome ?gamble /succ))))))
