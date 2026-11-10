; ----------------------------------------------------------------------------
; give-charity ?venue - go to the church and give alms there (GIVE-ALMS).
; ----------------------------------------------------------------------------

(task {@self give-charity ?venue}:?give-charity
  (tar [k church-building] @object)
  (and
    (try
      (belief (not (spatial @self building ?venue))
        (effects (maintain-proposal {@self enter-building ?venue}))))
    (try
      (belief (spatial @self building ?venue)
        (effects (maintain-proposal {@self GIVE-ALMS ?venue}))))
    (try
      (belief {@self GIVE-ALMS ?venue /succ /caused_by ?give-charity}
        (effects (set-outcome ?give-charity /succ))))))
