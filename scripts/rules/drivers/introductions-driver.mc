; ----------------------------------------------------------------------------
; Introductions, pursued. An intent to introduce two people to each other
; ({@self intent {@self introduce ?a ?b}}) comes from a birth: a mother makes the newborn and each
; of her other children known to each other (tasks/give-birth-task.mc). It is OPPORTUNISTIC:
; nobody is fetched or sought out - when both are with @self, she introduces them
; (tasks/introduce-task.mc). Begun, not maintained: co-presence decides whether she says it, and
; once said it is done, whoever walks off as she finishes.
; ----------------------------------------------------------------------------

(driver {@self intent {@self introduce ?a ?b}}:?intent
  (belief (spatial ?a co-located @self)
          (spatial ?b co-located @self)
    (lint-waive begin-proposal)
    (effects (begin-proposal {@self introduce ?a ?b}))))
