; ----------------------------------------------------------------------------
; wed ?occ - a wedding principal's own duty at the ceremony: get to the church and
; SPEAK the vow (say_to the betrothed "you are my spouse"). The vow is the one
; physical act - speech - by which the marriage is made; the party HEARS and adopts
; it (no fiat cross-mind write). Both principals hold {@self organize <wedding>} and
; each raises this duty; whoever vows first marries, the other HEARS and reciprocates
; (spouse_reciprocate, attend_think.hs) then fails the unmarried gate - the SAY-memory
; dedup covers the same-window gap before reciprocation lands. This duty is separate
; from (and runs alongside) the shared attend task; its own go rung gets him there.
; ----------------------------------------------------------------------------

(npc-task {@self wed ?occ}:?w-rel
  (tar occasion)
  (and
    ; VOW: at the church, still my betrothed, not yet vowed -> speak it.
    (try
      (role @self {@self fiancee ?betrothed} (none (is-married @self)))
      (role ?venue {?occ venue ?venue})
      (role @self (spatial @self building ?venue))
      (when (and (any {?occ hours ?start ?end})
                 (attend-in-window ?start ?end)
                 (none {@self SAY (msg {@self spouse ?betrothed}) ?betrothed})))
      (utility (* 10 (+ (attend-host-utility) 10)))
      (effects (maintain-proposal {@self SAY (utterable-msg {@self spouse ?betrothed}) ?betrothed})))

    ; GO: not at the church yet -> head to it (in the window).
    (try
      (role @self {@self fiancee ?} (none (is-married @self)))
      (role ?venue {?occ venue ?venue})
      (role @self (not (spatial @self building ?venue)))
      (when (and (any {?occ hours ?start ?end})
                 (attend-in-window ?start ?end)))
      (utility (* 10 (+ (attend-host-utility) 10)))
      (effects (maintain-proposal {@self enter ?venue})))))
