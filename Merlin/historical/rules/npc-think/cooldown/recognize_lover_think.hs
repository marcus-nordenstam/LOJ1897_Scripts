; ----------------------------------------------------------------------------
; recognize_lover (npc-think) - being a lover is RECOGNIZED, not minted by the sex act.
; Whenever @self holds a PAST-YEAR HAVE_SEX_WITH record with someone who is NOT his
; spouse, that someone is @self's `lover` (in hsim `lover` means specifically NOT-spouse;
; sleeping with your own wife never makes her a `lover`). Each mind recognises its OWN
; lover from its OWN sex record (@self's begun-ended act on his side, the reciprocal
; record HAVE_SEX_WITH writes on the paramour), so the bond forms on BOTH sides with NO
; cross-mind write - the recognition that replaces the old terminal-consummate fiat mint.
;
; begin-belief (latched, like affair/lovers), guarded on not-already-a-lover so it settles
; once; the reciprocal side is the paramour's own recognition firing, never a fiat here.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think recognize_lover
  (cooldown 1 m)
  (role @self)
  (role ?paramour (any_human ?paramour)
                  {@self HAVE_SEX_WITH ?paramour /ever}
                  (not {@self spouse ?paramour})
                  (not {@self lover ?paramour}))
  (when (< (days-since-last {@self HAVE_SEX_WITH ?paramour /ever}) 365))
  (effects (begin-belief {@self lover ?paramour})))
