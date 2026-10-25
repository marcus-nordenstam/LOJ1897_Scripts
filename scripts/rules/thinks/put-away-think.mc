; ----------------------------------------------------------------------------
; put-away - a wife told by her husband that he is no longer her husband (tasks/divorce-task.mc)
; has been put away: her own spouse bond ends and she knows herself a fallen woman.
; ----------------------------------------------------------------------------

(think put-away
  (role @self {@self gender [k female]}
    (role ?husband {@self spouse ?husband}
                   {?husband /not spouse @self}
      (effects
        (end-belief {@self spouse ?husband})
        (begin-belief {@self prototype [k fallen-woman]})))))
