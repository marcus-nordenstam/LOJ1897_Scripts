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
      (role ?station [k police-station] (select (score (near @self ?station)) (policy roulette)))
      (when (and {? stolen-from @self}
                 (can-write @self)
                 -{@self report-crime ?focus /succ /ever}
                 (not (spatial @self building ?station))))
      (utility errand)
      (effects (maintain-proposal {@self enter ?station})))
    ; knows no station -> search the region for one; the search's own /fail is what the
    ; abandon try below reads as "this town has no police station".
    (try
      (no-role [k police-station])
      (when (and {? stolen-from @self}
                 (can-write @self)
                 -{@self report-crime ?focus /succ /ever}
                 -{@self find-building [k police-station] ? /fail}
                 (current-region @self): ?rg))
      (utility errand)
      (effects (maintain-proposal {@self find-building [k police-station] ?rg})))
    (try
      (when (and {? stolen-from @self}
                 (can-write @self)
                 -{@self report-crime ?focus /succ /ever}
                 (is-a (spatial @self building) [k police-station])))
      (utility errand)
      (effects
        (if (alive ?focus) (then (begin-belief {@self suspect ?focus})))
        (for-each ?lb-rel (every {? stolen-from @self})
          (do
            (bind ?lb-rel.subject ?loot)
            (plant-letter [k crime-report-letter]
                          (if (alive ?focus)
                              (then (nl-written-msg "I suspect ?focus"))
                              (else (nl-written-msg "?loot was stolen from me")))
                          (spatial @self space))
            (break)))
        (set-outcome ?report-rel /succ)))
    (try
      (when (or -{? stolen-from @self}
                (not (can-write @self))
                {@self find-building [k police-station] ? /fail}
                {@self report-crime ?focus /succ /ever}))
      (effects (set-outcome ?report-rel /fail)))))
