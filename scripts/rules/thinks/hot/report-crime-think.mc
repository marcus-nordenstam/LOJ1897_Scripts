; ----------------------------------------------------------------------------
; pursue-report-crime - an intent to report a man to the police (minted by report-injustice /
; report-for-relief, thinks/cooldown/grievance-lawful-think.mc): with a police station known,
; file the report there; with none known, search the region for one first. The report
; concluding ends the intent; a search proving the town has none gives it up.
; ----------------------------------------------------------------------------

(driver {@self intent {@self report-crime ?target}}:?intent
  (and
    (try
      (role ?station [k police-station] (select (policy first-match))
        (effects (maintain-proposal {@self report-crime ?target}))))
    (try
      (no-role [k police-station])
      (when -{@self find-building [k police-station] ? /fail})
      (effects (maintain-proposal {@self find-building [k police-station] (current-exterior @self)})))))

(reflex {@self find-building [k police-station] ? /fail}
  (effects
    (for-each ?intent (every {@self intent {@self report-crime ?} /pres})
      (forsake-intent ?intent))))
