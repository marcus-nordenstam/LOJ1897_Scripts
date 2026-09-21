; ----------------------------------------------------------------------------
; stack_put ?doc ?stack - the one dumb hands act of filing a doc onto ?stack's
; top. The twin of stack_take. Filing a doc INTO a pile is env mutation, so only
; an ACTION may do it. THE general "put in a stack": posting mail into an outgoing
; pile, lodging a listing / deed into a registry stack, shelving any document.
; ----------------------------------------------------------------------------

(npc-action {@self STACK-PUT ?doc ?stack}:?put-rel
  (motor body legs)
  (obs)
  (tar @excl)
  (presentation
    (preroll 0.0) (in 0.3) (out 0.3))
  ; A presented filing is over the moment the hand lets go: the body ends the act on
  ; its first tick, so no clock caps it. The minute is the scheduled length.
  (duration
    (cond (case (presented-lod) procedural)
          (else (seconds 1 min))))
  (init
    (if (unsubstantial ?doc)
        (then (set-outcome ?put-rel /fail))))
  (effects
    (check (spatial ?stack co-located @self /env))
    (push ?doc ?stack)
    (observe ?doc)
    ; The paper is on a pile again, so it owes none a return: the note STACK-TAKE wrote when
    ; it came off one is discharged here, by the act that put it back.
    (bb-clear ?doc from-stack)
    ; A stack is its own destination, so unlike PUT there is nothing for the presented
    ; path to aim at beyond the pile: it reaches first, then files, and the act is one
    ; for both LODs. All the hand owes the scene here is letting go of the picture.
    (if (presented-lod)
        (then (detach-entity ?doc)))
    (set-outcome ?put-rel /succ)))
