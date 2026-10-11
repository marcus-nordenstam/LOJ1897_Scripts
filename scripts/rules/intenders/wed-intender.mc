; ----------------------------------------------------------------------------
; Marriage, pursued. An intent to wed ({@self intent {@self wed ?partner}}) comes from the groom's
; matching intenders (intenders/betrothal-intender.mc, advantageous-match-intender.mc,
; love-match-intender.mc) and from fancying the one you are betrothed to (decide-wed-for-love).
; pursue-wed works it through: propose to the partner, then - the groom - plan the wedding and
; invite the bride, and on the day wed at it, whoever organized it. Marrying ends the intent
; with its intenders.
; ----------------------------------------------------------------------------

(intender decide-wed-for-love
  (role ?partner {@self fiancee ?partner}
                 {@self fancy|desire|crave ?partner}:?fancy
                 -{@self spouse ?}
    (declare-utility want)
    (effects (maintain-intent {@self intent {@self wed ?partner}} /caused_by ?fancy))))

; A betrothal obliges: whoever holds one resolves to wed, whatever brought it about (an arranged
; groom may not fancy his bride).
(intender honour-betrothal
  (role ?partner {@self fiancee ?partner}:?betrothal
                 -{@self spouse ?}
    (declare-utility obligation)
    (effects (maintain-intent {@self intent {@self wed ?partner}} /caused_by ?betrothal))))
