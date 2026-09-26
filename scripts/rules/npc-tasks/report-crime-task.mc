; ----------------------------------------------------------------------------
; report-crime ?focus - the lawful channel: @self files a crime report at a police
; station over a theft they actually REMEMBER ({? stolen-from @self}, loot = subject).
; ?focus is the suspected culprit (or @fail - a loss with no known thief). NOT a crime -
; no ledger. @self walks to a police station they know and FILES the crime-report-letter
; there (a discoverable institutional record no resident reads), plus a {@self suspect
; ?focus} belief for a named live culprit. The ended {@self report-crime ?focus} belief
; IS the report memory (act/state doctrine) and the re-report dedup. Literacy required.
; Already reported this target, nothing stolen, illiterate, or no known station -> abandon.
; ----------------------------------------------------------------------------

(npc-task {@self report-crime ?focus}:?report-rel
  (tar ?)
  (and
    (try
      (role ?station [k police-station] (select (score (near @self ?station)) (policy roulette unknown-last))
        (role @self (not (spatial @self building ?station))
          (when (and {? stolen-from @self}
                     (can-write @self)
                     -{@self report-crime ?focus /succ /ever}
                     (not (is-a (spatial @self building) [k police-station]))))
          (utility errand)
          (effects (maintain-proposal {@self go ?station})))))
    ; knows no station -> search the region for one; the search's own /fail is what the
    ; abandon try below reads as "this town has no police station".
    (try
      (no-role [k police-station])
      (when (and {? stolen-from @self}
                 (can-write @self)
                 -{@self report-crime ?focus /succ /ever}
                 -{@self find-building [k police-station] ? /fail}
                 (current-exterior @self): ?rg))
      (utility errand)
      (effects (maintain-proposal {@self find-building [k police-station] ?rg})))
    (sequence
      (role @self
        (utility errand)
        (stage
          (when (and {? stolen-from @self}
                     (can-write @self)
                     -{@self report-crime ?focus /succ /ever}
                     (is-a (spatial @self building) [k police-station])))
          (effects
            (if (bb-any ?report-rel letter)
                (then (bind (bb-read ?report-rel letter) ?ltr))
                (else (maintain-proposal {@self CREATE-ENTITY [k crime-report-letter]}:?ce
                        [/postlude (bind (bb-read ?ce created) ?ltr)
                                   (bb-write ?report-rel letter ?ltr)])))))
        (stage
          (when (spatial ?ltr co-located @self))
          (effects
            (any {? stolen-from @self}).subject: ?loot
            (if (unsubstantial (attr ?ltr writing))
                (then (maintain-proposal
                        {@self write-doc ?ltr
                               (if (alive ?focus)
                                   (then (nl-written-msg "I suspect ?focus"))
                                   (else (nl-written-msg "?loot was stolen from me")))})))))
        (stage
          (effects
            (if (alive ?focus) (then (begin-belief {@self suspect ?focus})))
            (bb-clear ?report-rel letter)
            (set-outcome ?report-rel /succ)))))
    (try
      (when (or -{? stolen-from @self}
                (not (can-write @self))
                {@self find-building [k police-station] ? /fail}
                {@self report-crime ?focus /succ /ever}))
      (effects (set-outcome ?report-rel /fail)))))
