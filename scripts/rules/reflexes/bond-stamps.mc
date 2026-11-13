; ----------------------------------------------------------------------------
; bond-stamps (reflex) - the bonds born with a feeling already in them: a mother's for the child
; she bore, a newborn's for his mother, and the care a vow pledges. A stamp is one very strong
; experience, felt on the bond's birth and caused by the act that made the bond; the newborn
; never perceives his birth, so his stamp names no act.
; ----------------------------------------------------------------------------

(reflex {@self child ?baby /caused_by ?give-birth}:?child
  (when (dirty-born))
  (effects
    (feel-stance ?baby care (care-stamp-felt) ?give-birth)
    (feel-stance ?baby warmth (warmth-stamp-felt) ?give-birth)))

(reflex {@self mother ?woman}:?mother
  (when (dirty-born))
  (effects
    (feel-stance ?woman care (care-stamp-felt))
    (feel-stance ?woman warmth (warmth-stamp-felt))))

(reflex {@self spouse ?partner /caused_by ?vow}:?spouse
  (when (dirty-born))
  (effects (feel-stance ?partner care (care-stamp-felt) ?vow)))
