; ----------------------------------------------------------------------------
; prestige (classifier). Public standing as the 0..1 {@self prestige} float the
; class-situation and social-trajectory role-gates read: the job-rank curve
; (prestige_by_rank in tables/lookup-tables.hs, headship at the top) plus a capped
; sporting-victory bonus and a bump for an expert skill in a publicly-esteemed
; domain (performance art / academic field / martial). The competence band is the
; skilled-in belief's 4th field, so domain and band match in one clause.
;
; A value dim, not a band: prestige is a magnitude its consumers weight, so it is
; a plain float self-belief (@excl - a re-assert replaces), not a mint-band.
; Monthly cooldown: job level, wins and skill bands all drift continuously.
; ----------------------------------------------------------------------------

(npc-think classify_prestige
  (cooldown 1 m)
  (rng-stream behaviour)

  (role @self {@self class-situation ?})

  ; Economic rank: headship of a non-household org is the top band and trumps any
  ; level rung; a job with no level rung reads the entry band; the jobless read -1.
  (bind (if {@self job ?}
          (then (if (is-a (any {@self job ?}).target [k head-of-non-household-org])
                  (then 5)
                  (else (if (table-match level_rank level
                              (any {(any {@self job ?}).target level ?}).target rank ?rung)
                          (then ?rung)
                          (else 0)))))
          (else -1)) ?rank)

  (effects
    (begin-belief {@self prestige
      (clamp (+ (if (table-match prestige_by_rank rank ?rank prestige ?curve)
                  (then ?curve)
                  (else 0.15))
                (min (* (count (every {@self win ?})) 0.04) 0.20)
                (* 0.15
                   (min (+ (prob {@self skilled-in [k performance-art] [k competence-level expert]})
                           (prob {@self skilled-in [k academic-field]  [k competence-level expert]})
                           (prob {@self skilled-in [k martial]         [k competence-level expert]}))
                        1)))
             0 1)})))
