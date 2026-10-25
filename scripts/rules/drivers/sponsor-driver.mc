; ----------------------------------------------------------------------------
; sponsor - the patron's intent to take a protege under his wing (intenders/patronage-
; intender.mc) is carried out when the two meet: he proposes the sponsor task, which tells
; the protege he is backed.
; ----------------------------------------------------------------------------

(driver {@self intent {@self sponsor ?protege}}:?intent
  (role @self (spatial ?protege co-located @self)
    (effects (maintain-proposal {@self sponsor ?protege}))))
