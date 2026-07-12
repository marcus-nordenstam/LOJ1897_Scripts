; ----------------------------------------------------------------------------
; apprentice_errand (act lane) - the npc-ACT half of the apprenticeship split
; (Item 5). The go/dwell think rungs live in npc-think/apprentice_errand.hs.
;
; The decision (apprenticeship.hs `apprenticeship_start`) minted {@self goal
; {@self seek_indenture <master_articles>}}. The youth presents himself at the
; master's premises and is taken on there - the indenture + the master bond struck
; in person. The master's articles are the goal focus, so the premises are
; (articles-building (goal-focus seek_indenture)) and the master is
; (org-founder (goal-focus seek_indenture)).
;
;   indenture_act    : the promoted act - the 90-min articling; matched by its (when)
;                      on the promoted {@self seek_indenture} belief. Hires the youth,
;                      mints the master bond, ends the act + the aim.
; ----------------------------------------------------------------------------

; The 90-min articling. Promoted from the seek_indenture aim at the premises; its (when)
; matches the promoted {@self seek_indenture} belief + binds the master off the articles
; (dropping cleanly if unreadable). Ends both the running act and the aim on completion.
(npc-act indenture_act
  ; bind the master's articles to a plain ?var (a macro arg used as a {pattern}
  ; subject inside hire-seq must be a ?var, not an expr).
  (bind (goal-focus seek_indenture) ?art)
  (when (and (believes {@self seek_indenture})
             (org-founder ?art ?master)))
  (duration 90)
  (act-effects
    (hire-seq ?art [k job clerk] [k trainee])
    (begin-belief {@self master ?master})
    (end-act {@self seek_indenture})
    (end-goal {@self seek_indenture})))
