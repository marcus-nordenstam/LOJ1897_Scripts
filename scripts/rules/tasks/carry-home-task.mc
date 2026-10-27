; ----------------------------------------------------------------------------
; carry-home ?ware ?dest - carry the ware he holds to ?dest and set it down at a free spot
; there (BRING).
; ----------------------------------------------------------------------------

(task {@self carry-home ?ware ?dest}:?carry-home
  (tar ?)
  (aux ?)
  (and
    (try
      (role @self (not (spatial @self space ?dest))
        (effects (maintain-proposal {@self go-to ?dest}))))
    (try
      (role @self (spatial @self space ?dest)
        (when (poll (rest-spot ?dest (held-ware @self ?ware)): ?spot))
        (effects (maintain-proposal {@self BRING ?ware ?spot}))))
    (try
      (role @self (spatial @self space ?dest)
        (when (poll (not (rest-spot ?dest (held-ware @self ?ware)))))
        (effects (set-outcome ?carry-home /fail))))
    (try
      (role @self {@self BRING ?ware ? /succ /caused_by ?carry-home}
        (effects (set-outcome ?carry-home /succ))))))
