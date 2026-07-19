; ----------------------------------------------------------------------------
; fallen_woman (per-observer). Each mind marks {?other prototype [k fallen_woman]}
; in its OWN pool for a married woman it believes has taken a lover - i.e. an
; adulterous liaison THIS observer has heard of. Replaces the omniscient annual
; classify_fallen_woman (which walked every circle mind via secret_partner_leaked
; to decide if the affair had "leaked", then broadcast a uniform mark). Now the
; mark is genuinely per-observer: only those who know of the affair treat her as
; fallen, and it fades if they forget it. mint-band-about writes the belief ABOUT
; ?other into @self's own pool - never into ?other's mind.
;
; The lover himself does NOT mark her (he holds {@self lover ?her}, subject @self -
; a different subject - so (believes {?her lover ?}) is false for him); only THIRD
; parties who learned of the liaison ({?her lover <partner>}) do. The divorce path
; (affair_fallout.hs) still marks + dismisses her directly, and the widow / unmarried
; cases (no ongoing spouse) are left to that path - this catches the "still married,
; the town has heard" fall. The (or ... held-fallen) input keeps the event on-agenda
; to toggle the mark OFF if the observer forgets the liaison (per-observer rehab).
; ----------------------------------------------------------------------------

(npc-think classify_others_fallen_woman
  (sim-window-think)
  (rng-stream behaviour)

  (role ?other (believes {?other gender [k female]})
               (believes {?other spouse ?})
               (or (believes {?other lover ? /ever})
                   (believes {?other prototype [k fallen_woman]})))

  (cont-fire-effects
    (mint-band-about {?other prototype} (believes {?other lover ? /ever})
      [k fallen_woman] 0.5)))
