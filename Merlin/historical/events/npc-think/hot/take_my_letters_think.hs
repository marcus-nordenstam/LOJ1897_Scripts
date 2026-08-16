; ----------------------------------------------------------------------------
; take_my_letters ?stack - sort the stack's TOP doc, one doc at a time: a doc
; addressed to ME (my name, or a duty I hold) is LIFTED into hand (stack_take);
; anything else is BURIED to the bottom (stack_bury), exposing the next doc -
; stack-top uniqueness is what serializes the iteration. A buried doc is marked
; handled on the private bb by the bury act's POSTLUDE (so the mark lands only
; once the burial really happened), and the round concludes when the stack is
; empty or an already-handled doc resurfaces as top - the full cycle has been
; seen. The reasoning lives HERE; the acts are dumb stack moves.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think take_my_letters_scan
  (task {@self take_my_letters ?stack}:?take-letters)
  (role @self {@self name ?name})
  (role ?doc [k document] {?stack top ?doc}
             (not (= (bb-read ?doc tml-status) handled)))
  (effects
    (tolerate (attr ?doc addressee): ?addressee)
    (tolerate (attr ?doc addressee_duty): ?duty)
    (if (or (= ?addressee ?name)
            (believes {@self duty_to ? ?duty}))
        (then (debug-print "TML_LIFT doc=?doc")
              (maintain-proposal {@self STACK_TAKE ?doc ?stack}))
        (else (debug-print "TML_BURY doc=?doc adr=?addressee duty=?duty")
              (maintain-proposal {@self STACK_BURY ?doc ?stack}
                  (postlude (bb-write ?doc tml-status handled)))))))

(npc-think take_my_letters_done
  (task {@self take_my_letters ?stack}:?take-letters)
  (when (or (none {?stack top @something})
            (and (any {?stack top @something}).target: ?top
                 (= (bb-read ?top tml-status) handled))))
  (effects
    (bb-clear ? tml-status)
    (set-outcome ?take-letters succ)))

(npc-think take_my_letters_tmp_p1
  (task {@self take_my_letters ?stack})
  (effects (debug-print "TML_P_TASK stk=?stack")))

(npc-think take_my_letters_tmp_p2
  (task {@self take_my_letters ?stack})
  (role @self {@self name ?name})
  (effects (debug-print "TML_P_NAME")))

(npc-think take_my_letters_tmp_p3
  (task {@self take_my_letters ?stack})
  (role ?doc [k document] {?stack top ?doc})
  (effects (debug-print "TML_P_TOP doc=?doc")))
