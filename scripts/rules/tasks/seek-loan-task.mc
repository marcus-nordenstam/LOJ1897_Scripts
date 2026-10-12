; ----------------------------------------------------------------------------
; seek-loan ?creditor - call on the creditor at the home @self knows for him and strike the
; loan there (TAKE-LOAN records the debt).
; ----------------------------------------------------------------------------

(task {@self seek-loan ?creditor}:?seek-loan
  (tar [k human] @object)
  (and
    (try
      (role ?cred_home {?creditor home ?cred_home}
                       (not (spatial @self building ?cred_home))
                       (go-reachable ?cred_home)
        (effects (maintain-proposal {@self go-to ?cred_home}))))
    (try
      (role ?cred_home {?creditor home ?cred_home}
                       (spatial @self building ?cred_home)
        (effects (maintain-proposal {@self TAKE-LOAN ?creditor}))))
    (try
      (when {@self TAKE-LOAN ?creditor /succ /caused_by ?seek-loan})
      (effects (set-outcome ?seek-loan /succ)))
    (try
      (when {?creditor condition [k dead]})
      (effects (set-outcome ?seek-loan /fail)))))
