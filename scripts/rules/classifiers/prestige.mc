; ----------------------------------------------------------------------------
; prestige (classifier). Public standing as the 0..1 {@self prestige} float the
; class-situation and social-trajectory role-gates read: the job-rank curve
; (prestige_by_rank below, headship at the top) plus a capped
; sporting-victory bonus and a bump for an expert skill in a publicly-esteemed
; domain (performance art / academic field / martial). The competence band is the
; skilled-in belief's 4th field, so domain and band match in one clause.
;
; A value dim, not a band: prestige is a magnitude its consumers weight, so it is
; a plain float self-belief (@excl - a re-assert replaces), not a mint-band.
; Monthly cooldown: job level, wins and skill bands all drift continuously.
; ----------------------------------------------------------------------------

; job rank -> the prestige dimension it confers (0..1). rank is the level_rank
; rung (0 trainee .. 4 senior), 5 for headship of a non-household org, and -1
; for an NPC holding no job at all (the unemployed floor).
(define-table prestige_by_rank
  (fields rank prestige)
  (record -1 0.15)
  (record  0 0.20)
  (record  1 0.20)
  (record  2 0.30)
  (record  3 0.45)
  (record  4 0.65)
  (record  5 0.90))

(npc-think classify_prestige
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  (role @self {@self class-situation ?}

    ; Economic rank: headship of a non-household org is the top band and trumps any
    ; level rung; a job with no level rung reads the entry band; the jobless read -1.
    (bind (cond
            (case -{@self job ?} -1)
            (case (is-a (any {@self job ?}).target [k head-of-non-household-org]) 5)
            (case (table-match level_rank level
                               (any {(any {@self job ?}).target level ?}).target rank ?rung)
              ?rung)
            (else 0)) ?rank)

    (effects
      (begin-belief {@self prestige
        (clamp (+ (if (table-match prestige_by_rank rank ?rank prestige ?curve)
                    (then ?curve)
                    (else 0.15))
                  (min (* (count (every {@self win ?}) /float) 0.04) 0.20)
                  (* 0.15
                     (min (+ (prob {@self skilled-in [k performance-art] [k competence-level expert]})
                             (prob {@self skilled-in [k academic-field]  [k competence-level expert]})
                             (prob {@self skilled-in [k martial]         [k competence-level expert]}))
                          1.0)))
               0.0 1.0)}))))
