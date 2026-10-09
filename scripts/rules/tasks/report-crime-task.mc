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

(task {@self report-crime ?focus}:?report-crime
  (tar ?)
  (and
    (try
      (role ?station [k police-station] (select (score (near @self ?station)) (policy roulette unknown-last))
        (role @self {@self education ?education}
                    (not (spatial @self building ?station))
          (when (and {? stolen-from @self}
                     (>= ?education (literacy-education-min))
                     -{@self report-crime ?focus /succ /ever}
                     (not (is-a (spatial @self building) [k police-station]))))
          (declare-utility errand)
          (effects (maintain-proposal {@self go-to ?station})))))
    ; knows no station -> search the region for one; the search's own /fail is what the
    ; abandon try below reads as "this town has no police station".
    (try
      (no-role [k police-station])
      (role @self {@self education ?education}
        (when (and {? stolen-from @self}
                   (>= ?education (literacy-education-min))
                   -{@self report-crime ?focus /succ /ever}
                   -{@self find-building [k police-station] ? /fail}
                   (current-exterior @self): ?rg))
        (declare-utility errand)
        (effects (maintain-proposal {@self find-building [k police-station] ?rg}))))
    (sequence
      (role @self {@self education ?education}
        (declare-utility errand)
        (stage
          (when (and {? stolen-from @self}
                     (>= ?education (literacy-education-min))
                     -{@self report-crime ?focus /succ /ever}
                     (is-a (spatial @self building) [k police-station])))
          (effects
            (if (bb-any ?report-crime letter)
                (then (bind (bb-read ?report-crime letter) ?ltr))
                (else (maintain-proposal {@self CREATE-ENTITY [k crime-report-letter]}:?CREATE-ENTITY
                        [/postlude (bind (bb-read ?CREATE-ENTITY created) ?ltr)
                                   (bb-write ?report-crime letter ?ltr)])))))
        (stage
          (when (spatial ?ltr co-located @self))
          (effects
            (any {?loot stolen-from @self})
            (if (unsubstantial (attr ?ltr writing))
                (then (maintain-proposal
                        {@self write-doc ?ltr
                               (if (alive ?focus)
                                   (then (nl-written-msg "I suspect ?focus"))
                                   (else (nl-written-msg "?loot was stolen from me")))})))))
        (stage
          (effects
            (if (alive ?focus) (then (begin-belief {@self suspect ?focus})))
            (bb-clear ?report-crime letter)
            (set-outcome ?report-crime /succ)))))
    (try
      (when (or -{? stolen-from @self}
                -{@self education ?}
                {@self find-building [k police-station] ? /fail}
                {@self report-crime ?focus /succ /ever}))
      (effects (set-outcome ?report-crime /fail)))
    (try
      (role @self {@self education ?education}
        (when (< ?education (literacy-education-min)))
        (effects (set-outcome ?report-crime /fail))))))
