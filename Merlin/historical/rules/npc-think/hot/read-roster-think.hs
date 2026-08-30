; ----------------------------------------------------------------------------
; read_roster - the workday habit of keeping track of WHO you work with: every
; employee re-reads the staff register on their firm's wall and refreshes their
; picture of their colleagues.
;
; The COWORKER-awareness counterpart to materialize_employment (which rebuilds
; @self's OWN post from its roster row): this rebuilds @self's beliefs about the
; COLLEAGUES on the same roster, and RETRACTS colleagues who have dropped off it.
; All single-POV - @self reads a PUBLIC document; no colleague's mind is entered.
;
; find-my-enrollment locates the articles of the org whose roster lists @self (the
; objective register scan materialize_employment uses); its register is then walked.
; The colleague job objects mirror @self's own job-object shape (imagine-or-recall
; over the roster `job` kind + {?cojob org ?org} + {?cojob level ?lvl}), so
; workplace-social rules (ambition, ...) role-cast colleagues off {?cw job.org
; ?org} and read rank / head-ness ({?cw job [k org_head]}) with no telepathy.
;
; hsim deliberates at MONTHLY resolution, so the "read the sign at work" habit
; renders as a monthly roster-refresh - the cadence at which hires / departures
; happen too, so nothing is missed.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think read_roster
  (cooldown 1 m)
  (rng-stream employment)

  (role ?job {@self job ?job})
  (role ?org {?job org ?org})
  (when (or (in-month 3) (in-month 6) (in-month 9) (in-month 12)))

  (effects
    ; My firm's register hangs off my own {?org employee_register ?reg} belief - learned
    ; when I read the incorporation page at hire/orient (hire-beliefs adopt-msg). A belief
    ; walk, no doc scan. ?org (my job.org, role above) is where colleague beliefs hang so
    ; they JOIN my own {@self job.org ?org}. Any duty-holder reuses this by binding ?org.
    (any {?org employee_register ?reg})
    (check ?reg)

    ; (1) REFRESH - one colleague job object per roster row (skip my own row), mirroring
    ; my own job object so {?cw job.org ?org} / rank / head-ness read uniformly.
    (for-each-row (attr ?reg writing) (worker ?cw) (job ?jk) (level ?lvl)
      (if (!= ?cw @self)
          (then
            (o ?jk {?cw job @o}): ?cojob
            (begin-belief {?cojob org ?org})
            (begin-belief {?cojob level ?lvl}))))

    ; (2) RECONCILE (negative confirmation) - forget colleagues no longer listed: walk the
    ; job objects I believe belong to ?org, bind each holder, and drop the tie for any holder
    ; (not me) no longer on a worker row.
    (for-each ?ojb-rel (every {? org ?org})
      (bind ?ojb-rel.subject ?ojob)
      (for-each ?jb-rel (every {? job ?ojob})
        (bind ?jb-rel.subject ?other)
        (if (and (!= ?other @self)
                 (not (table-match (attr ?reg writing) worker ?other)))
            (then (end-belief ?jb-rel)))))))
