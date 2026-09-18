; ----------------------------------------------------------------------------
; stack_bury - the dumb hands act of stack iteration. Files the held ?doc at ?stack's
; BOTTOM (the grip releases as part of the bury), beneath every other filing.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-action {@self STACK-BURY ?doc ?stack}:?bury-rel
  (duration (minutes 1))
  (effects
    ; The twin of STACK-TAKE's: a man files a paper in the pile he is standing at.
    (check (spatial ?stack co-located @self /env))
    (bury ?doc ?stack)
    ; The paper is on a pile again, so it owes none a return: the note STACK-TAKE wrote when
    ; it came off one is discharged here, by the act that put it back.
    (bb-clear ?doc from-stack)
    ; He is still standing at the pile he just filed into - the twin of STACK-TAKE's re-look.
    (tolerate (observe (spatial ?stack top /env)))
    (set-outcome ?bury-rel /succ)))
