; ----------------------------------------------------------------------------
; seek-appointment ?art - take up a senior official's post in the org ?art declares: give
; up his present post, go to the org's premises, enter himself on its register at the
; senior level, and read the row back as his own employment.
; ----------------------------------------------------------------------------

(npc-task {@self seek-appointment ?art}:?sa-rel
  (tar [k document] @object)
  (and
    (try
      (role @self {@self job ?}
                  -{@self QUIT-WORK /succ /caused_by ?sa-rel}
        (effects (maintain-proposal {@self QUIT-WORK}))))
    (try
      (role @self -{@self job ?}
        (role ?art_org {?art_org record ?art}
                        {?art_org workplace ?venue}
                        (not (spatial @self building ?venue))
          (effects (maintain-proposal {@self go ?venue})))))
    (try
      (role @self -{@self job ?}
        (when (and (articles-building ?art ?venue)
                   (spatial @self building ?venue)))
        (effects
          (o {?art declares-org @o}): ?org
          (any {?org employee-register ?reg})
          (if ?reg (then (maintain-proposal {@self ENROL ?reg '[[k job official] [k senior]]}))))))
    (try
      (role ?art_org {?art_org record ?art}
                      {?art_org workplace ?venue}
                      (spatial @self building ?venue)
        (effects
          (o {?art declares-org @o}): ?org
          (any {?org employee-register ?reg})
          (if (table-match (attr ?reg writing) worker (name @self) level ?lvl)
              (then
                (hire-beliefs ?art [k job official] ?lvl)
                (set-outcome ?sa-rel /succ))))))))
