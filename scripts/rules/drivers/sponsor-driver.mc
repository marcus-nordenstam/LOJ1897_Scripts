; ----------------------------------------------------------------------------
; sponsor - the patron's intent to take a protege under his wing (intenders/patronage-
; intender.mc) is carried out when the two meet: he proposes the sponsor task, which tells
; the protege he is backed.
; ----------------------------------------------------------------------------

(driver {@self intent {@self sponsor ?protege}}:?intent
  (role @self (spatial ?protege co-located @self)
    ; Begun, not maintained: the meeting decides whether he speaks to the protege, and once begun
    ; it is done wherever the protege walks.
    (lint-waive begin-proposal)
    (effects (begin-proposal {@self sponsor ?protege}))))
