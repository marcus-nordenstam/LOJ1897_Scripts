; ----------------------------------------------------------------------------
; stock-larder ?kitchen - the cook's household provisioning, STOPGAPPED: he goes to his own
; kitchen and STOCK-LARDER conjures the basket the shopping errand (tasks/provision-task.mc)
; would have bought. Proposed by want-provisions-driver (drivers/provisioning-driver.mc).
; Deleted with actions/STOCK-LARDER.mc when shopping works.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")
(include "../../macros/collection-macros.mc")

(task {@self stock-larder ?kitchen}:?stock-larder
  (belief-timeout 1 h)
  (tar ?)
  (and
    (try
      (belief (not (spatial @self space ?kitchen))
        (effects (maintain-proposal {@self enter-room ?kitchen}))))
    (try
      (belief (spatial @self space ?kitchen)
        (when (and (provision-basket ?kitchen): ?basket
                   (> ?basket 0)))
        (when (poll (claim (rest-spot ?kitchen [k pile]) [k pile]): ?spot))
        (effects (maintain-proposal {@self STOCK-LARDER ?spot ?basket}))))
    (try
      (belief (spatial @self space ?kitchen)
        (when (<= (provision-basket ?kitchen) 0))
        (effects (set-outcome ?stock-larder /succ))))
    (try
      (belief (spatial @self space ?kitchen)
        (when (poll (not (claim (rest-spot ?kitchen [k pile]) [k pile]))))
        (effects (set-outcome ?stock-larder /fail))))
    (try
      (belief {@self STOCK-LARDER ? ? /succ /caused_by ?stock-larder}
        (effects (set-outcome ?stock-larder /succ))))))
