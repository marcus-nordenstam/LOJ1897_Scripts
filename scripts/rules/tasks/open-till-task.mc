; ----------------------------------------------------------------------------
; open-till ?shop - start the shop's till: an empty coin pile counted off the keeper's
; carrying cash and set down in the room he stands in. Buyers pay into it.
; ----------------------------------------------------------------------------

(task {@self open-till ?shop}:?open-till
  (tar [k shop] @object)
  (and
    (sequence
      (role ?cash {@self carrying-cash ?cash}

        (stage
          (effects
            (if (and (not (bb-any ?open-till till))
                     (empty (spatial (spatial @self right-hand) grip)))
                (then (maintain-proposal {@self PILE-SPLIT ?cash 0}:?PILE-SPLIT
                        [/postlude (bb-write ?open-till till (bb-read ?PILE-SPLIT created))])))))

        (stage
          (when (bb-any ?open-till till))
          (bind (bb-read ?open-till till) ?till)
          (effects
            (if (= (spatial ?till held-by) @self)
                (then (maintain-proposal {@self put ?till (spatial @self space)})))))))
    (try
      (when {@self /succ put ? ? /caused_by ?open-till})
      (effects (set-outcome ?open-till /succ)))))
