; ----------------------------------------------------------------------------
; prestige (classifier). Public standing as the 0..1 {@self prestige} float the
; class_situation and social_trajectory role-gates read: the job-rank curve
; (prestige_by_rank, headship at the top) plus a capped sporting-victory bonus and
; a bump for an expert skill in a publicly-esteemed domain. (prestige-fold) in
; dimensions.hs carries the encoding; this rule only mints it.
;
; A value dim, not a band: prestige is a magnitude its consumers weight, so it is
; a plain float self-belief (@excl - a re-assert replaces), not a mint-band.
; Monthly cooldown: the inputs (job level, wins, skill band) drift continuously.
; ----------------------------------------------------------------------------

(npc-think classify_prestige
  (cooldown 1 m)
  (rng-stream behaviour)

  (role @self {@self class_situation ?})

  (effects
    (begin-belief {@self prestige (prestige-fold @self)})))
