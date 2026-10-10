; ----------------------------------------------------------------------------
; give-charity ?venue - go to the church and give alms there (GIVE-ALMS).
; ----------------------------------------------------------------------------

(task {@self give-charity ?venue}:?give-charity
  (tar [k church-building] @object)
  (and
    (try
      (role @self (not (spatial @self building ?venue))
        (effects (maintain-proposal {@self go-to ?venue}))))
    (try
      (role @self (spatial @self building ?venue)
        (effects (maintain-proposal {@self GIVE-ALMS ?venue}))))
    (try
      (when {@self GIVE-ALMS ?venue /succ /caused_by ?give-charity})
      (effects (set-outcome ?give-charity /succ)))))
