; ----------------------------------------------------------------------------
; unpocket-coins ?count - count ?count coins out of the carrying-cash-pile into a free hand,
; the right if it is free, else the left. With both hands full, or fewer coins than ?count
; carried, it fails.
; ----------------------------------------------------------------------------

(task {@self unpocket-coins ?count}:?unpocket-coins
  (tar ?)
  (and
    (try
      (role ?carrying-cash-pile {@self carrying-cash-pile ?carrying-cash-pile}
        (when (and -{@self /succ PILE-SPLIT-LEFT|PILE-SPLIT-RIGHT ? ? /caused_by ?unpocket-coins}
                   (empty (spatial (spatial @self right-hand) grip))))
        (effects
          (maintain-proposal {@self PILE-SPLIT-RIGHT ?carrying-cash-pile ?count}))))
    (try
      (role ?carrying-cash-pile {@self carrying-cash-pile ?carrying-cash-pile}
        (when (and -{@self /succ PILE-SPLIT-LEFT|PILE-SPLIT-RIGHT ? ? /caused_by ?unpocket-coins}
                   (not (empty (spatial (spatial @self right-hand) grip)))
                   (empty (spatial (spatial @self left-hand) grip))))
        (effects
          (maintain-proposal {@self PILE-SPLIT-LEFT ?carrying-cash-pile ?count}))))
    (try
      (when {@self /succ PILE-SPLIT-LEFT|PILE-SPLIT-RIGHT ? ? /caused_by ?unpocket-coins})
      (effects (set-outcome ?unpocket-coins /succ)))
    (try
      (when (and -{@self /succ PILE-SPLIT-LEFT|PILE-SPLIT-RIGHT ? ? /caused_by ?unpocket-coins}
                 (or (< (carrying-cash-pile-count @self) ?count)
                     (and (not (empty (spatial (spatial @self right-hand) grip)))
                          (not (empty (spatial (spatial @self left-hand) grip)))))))
      (effects (set-outcome ?unpocket-coins /fail)))))
