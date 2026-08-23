; ----------------------------------------------------------------------------
; fallen_woman (per-observer). Each mind marks {?other prototype [k fallen_woman]}
; in its OWN pool for a married woman it believes has taken a lover - i.e. an
; adulterous liaison THIS observer has heard of. The mark is per-observer: only
; those who know of the affair treat her as fallen, and it fades if they forget it.
; mint-band-about writes the belief ABOUT ?other into @self's own pool - never into
; ?other's mind.
;
; The lover himself does NOT mark her (he holds {@self lover ?her}, subject @self -
; a different subject - so (any {?her lover ?} (out exists-bool)) is false for him); only THIRD
; parties who learned of the liaison ({?her lover <partner>}) do. The divorce path
; (affair_fallout.hs) still marks + dismisses her directly, and the widow / unmarried
; cases (no ongoing spouse) are left to that path - this catches the "still married,
; the town has heard" fall. The (or ... held-fallen) input keeps the event eligible so
; the mark can toggle OFF if the observer forgets the liaison (per-observer rehab).
; ----------------------------------------------------------------------------

(npc-think classify_others_fallen_woman
  ; Per-observer: marks / un-marks ?other from the liaison beliefs @self holds (gender / spouse /
  ; lover / prototype role filters). The mint-band hysteresis makes a same-band value a no-op.
  (rng-stream behaviour)

  (role ?other {?other gender [k female]}
               {?other spouse ?}
               (or {?other lover ? /ever}
                   {?other prototype [k fallen_woman]}))

  (effects
    (mint-band-about {?other prototype} (prob {?other lover ? /ever})
      [k fallen_woman] 0.5)))
