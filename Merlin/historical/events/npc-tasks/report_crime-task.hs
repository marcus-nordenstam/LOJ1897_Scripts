; ----------------------------------------------------------------------------
; report_crime ?focus - the lawful channel: @self files a crime report at a police
; station over a theft they actually REMEMBER ({? stolen_from @self}, loot = subject).
; ?focus is the suspected culprit (or @fail - a loss with no known thief). NOT a crime -
; no ledger. @self walks to a police station they know and FILES the crime_report_letter
; there (a discoverable institutional record no resident reads), plus a {@self suspect
; ?focus} belief for a named live culprit. The ended {@self report_crime ?focus} belief
; IS the report memory (act/state doctrine) and the re-report dedup. Literacy required.
; Already reported this target, nothing stolen, illiterate, or no known station -> abandon.
; ----------------------------------------------------------------------------

(npc-task {@self report_crime ?focus}:?report-rel
  (tar ?)
  (and
    (try
      (when (and (any {? stolen_from @self} (out exists-bool))
                 (can-write @self)
                 (none {@self report_crime ?focus /succ /ever})
                 (find-building [k police_station]): ?station
                 (not (spatial @self building ?station))))
      (utility errand)
      (effects (maintain-proposal {@self enter ?station})))
    (try
      (when (and (any {? stolen_from @self} (out exists-bool))
                 (can-write @self)
                 (none {@self report_crime ?focus /succ /ever})
                 (find-building [k police_station]): ?station
                 (spatial @self building ?station)))
      (utility errand)
      (effects
        (if (alive ?focus) (then (begin-belief {@self suspect ?focus})))
        (for-each ?lb-rel (every {? stolen_from @self})
          (do
            ?lb-rel.subject: ?loot
            (plant-letter [k crime_report_letter]
                          (if (alive ?focus)
                              (then (nl_written_msg "I suspect ?focus"))
                              (else (nl_written_msg "?loot was stolen from me")))
                          (spatial @self space))
            (break)))
        (set-outcome ?report-rel succ)))
    (try
      (when (or (not (any {? stolen_from @self} (out exists-bool)))
                (not (can-write @self))
                (not (find-building [k police_station]))
                (any {@self report_crime ?focus /succ /ever} (out exists-bool))))
      (effects (set-outcome ?report-rel fail)))))
