; ----------------------------------------------------------------------------
; apprentice_errand (act lane) - the npc-ACT half of the apprenticeship split
; (Item 5). The go/dwell think rungs live in npc-think/apprentice_errand.hs.
;
; The decision (apprenticeship.hs `apprenticeship_start`) minted {@self goal
; {@self seek_indenture <master_articles>}}. The youth presents himself at the
; master's premises and is taken on there - the indenture + the master bond struck
; in person. The master's articles are the act focus (?art, bound in the pattern);
; the premises are its articles-building and the master its org-founder.
;
;   indenture_action : the promoted act - the 90-min articling; proposed by
;                      indenture_dwell at the premises. Hires the youth, mints the
;                      master bond, ends the act. The seek_indenture aim is ended by
;                      its minter (apprenticeship_start) on the falling edge.
; ----------------------------------------------------------------------------

; The 90-min articling. Proposed at the premises; binds the master off the articles
; (dropping cleanly if unreadable). Ends the running act on completion; the aim is ended
; by its minter's falling-edge cease, not here.
(npc-action {@self seek_indenture ?art}
  (duration 90)
  (effects
    ; read the master off the articles (org-founder = a doc-read binding ?master); a
    ; pure re-derivation, not a gate - the is-entity guard drops cleanly if unreadable.
    (org-founder ?art ?master)
    (if (is-entity ?master)
      (then
        (hire-seq ?art [k job clerk] [k trainee])
        (begin-belief {@self master ?master})))
    (set-outcome {@self seek_indenture} succ)))
