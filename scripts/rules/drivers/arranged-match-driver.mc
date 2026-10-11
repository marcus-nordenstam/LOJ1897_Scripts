; ----------------------------------------------------------------------------
; arranged-match - a father whose life aims at respectability or wealth resolves to marry an
; unmarried daughter to a man of his own class. pursue-arrange-match carries it out
; (tasks/arrange-match-task.mc): the daughter is told to wed him or be disinherited, and both
; are told they are betrothed.
; ----------------------------------------------------------------------------

(driver {@self intent {@self arrange-match ?daughter ?groom}}:?intent
  (effects (maintain-proposal {@self arrange-match ?daughter ?groom})))
