; ----------------------------------------------------------------------------
; pocket-coins ?pile - put a coin pile held in hand into the carrying-cash-pile. What a man
; does with coins he has received (receive), never with coins he counted out to pay.
; ----------------------------------------------------------------------------

(task {@self pocket-coins ?pile}:?pocket-coins
  (tar [k pile] @object)
  (and
    (try
      (role ?carrying-cash-pile {@self carrying-cash-pile ?carrying-cash-pile}
                                (spatial @self can-reach ?carrying-cash-pile)
        (when (= (spatial ?pile held-by) @self))
        (effects (maintain-proposal {@self PILE-TRANSFER ?pile ?carrying-cash-pile}))))
    (try
      (role @self {@self /succ PILE-TRANSFER ?pile ? /caused_by ?pocket-coins}
        (effects (set-outcome ?pocket-coins /succ))))
    (try
      (when (and (!= (spatial ?pile held-by) @self)
                 -{@self /succ PILE-TRANSFER ?pile ? /caused_by ?pocket-coins}))
      (effects (set-outcome ?pocket-coins /fail)))))
