; ----------------------------------------------------------------------------
; wed ?occ - a wedding principal's own duty at the ceremony: get to the church and
; SPEAK the vow (say_to the betrothed "you are my spouse"). The vow is the one
; physical act - speech - by which the marriage is made; the party HEARS and adopts
; it (no fiat cross-mind write). Both principals hold {@self organize <wedding>} and
; each raises this duty; whoever vows first marries, the other HEARS and reciprocates
; (spouse-reciprocate, attend_think.mc) then fails the unmarried gate - the tell-memory
; dedup covers the same-window gap before reciprocation lands. This duty is separate
; from (and runs alongside) the shared attend task; its own go rung gets him there.
; ----------------------------------------------------------------------------

(task {@self wed ?occ}:?wed
  (tar [k occasion] @object)
  (and
    ; ALARM: think again when the window opens.
    (try
      (when {?occ hours ?start ?end})
      (effects (set-occasion-alarm ?start)))

    ; VOW: at the church, still my betrothed, not yet vowed -> speak it.
    (try
      (role @self {@self fiancee ?betrothed} (none {@self spouse @something})
        (role ?venue {?occ venue ?venue}
          (role @self (spatial @self building ?venue)
            (when (and {?occ hours ?start ?end}
                       (hours (- ?start (attend-prep-lead)) ?end)
                       -{@self tell (msg ? {@self spouse ?betrothed}) ?betrothed /succ}))
            (effects (maintain-proposal {@self tell (utterable-msg [] {@self spouse ?betrothed}) ?betrothed}))))))

    ; GO: not at the church yet -> head to it (in the window).
    (try
      (role @self {@self fiancee ?} (none {@self spouse @something})
        (role ?venue {?occ venue ?venue}
          (role @self (not (spatial @self building ?venue))
            (when (and {?occ hours ?start ?end}
                       (hours (- ?start (attend-prep-lead)) ?end)))
            (effects (maintain-proposal {@self go ?venue}))))))))
