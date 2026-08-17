; ----------------------------------------------------------------------------
; take_my_letters ?stack - sort ?stack's docs via the GENERIC stack_browse
; (stack_browse_think.hs): browse surfaces each doc into the hand marked
; pending; this consumer KEEPS the ones addressed to ME (my name, or a duty I
; hold) and marks everything else handled, which browse re-files at the
; bottom. Concludes when the browse round concludes.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think take_my_letters_browse
  (task {@self take_my_letters ?stack}:?take-letters)
  (when (none {@self stack_browse ?stack /caused_by ?take-letters /ever}))
  (utility errand)
  (effects
    (debug-print "TML_BROWSE")
    (begin-proposal {@self stack_browse ?stack})))

; The per-doc decision: mine -> kept (stays in hand); not mine -> handled
; (browse buries it back).
(npc-think take_my_letters_decide
  (task {@self take_my_letters ?stack}:?take-letters)
  (role @self {@self name ?name})
  (role ?doc [k document] (spatial @self hold)
        (= (bb-read ?doc browse-status) pending))
  (effects
    (tolerate (attr ?doc addressee): ?addressee)
    (tolerate (attr ?doc addressee_duty): ?duty)
    (if (or (= ?addressee ?name)
            (believes {@self duty_to ? ?duty}))
        (then (debug-print "TML_KEEP doc=?doc")
              (bb-write ?doc browse-status kept))
        (else (debug-print "TML_HANDLE doc=?doc")
              (bb-write ?doc browse-status handled)))))

(npc-think take_my_letters_done
  (task {@self take_my_letters ?stack}:?take-letters)
  (when (any {@self stack_browse ?stack /succ /caused_by ?take-letters}))
  (effects
    (debug-print "TML_DONE")
    (set-outcome ?take-letters succ)))

; Walked away from the stack mid-round -> conclude /fail (the same conclusive-not-
; interrupt rule as read_mail_give_up: a resumable standalone node would re-promote
; and stack-sort from afar). The next read_mail instance re-proposes a fresh round.
(npc-think take_my_letters_away
  (task {@self take_my_letters ?stack}:?take-letters)
  (when (not (co-present ?stack @self)))
  (effects
    (bb-clear ?stack browse-cycle-end)
    (bb-clear ?stack browse-inflight)
    (set-outcome ?take-letters fail)))

(npc-think take_my_letters_tmp_p1
  (task {@self take_my_letters ?stack})
  (effects (debug-print "TML_P_TASK stk=?stack")))
