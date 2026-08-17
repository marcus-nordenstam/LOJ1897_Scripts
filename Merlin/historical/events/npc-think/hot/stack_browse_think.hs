; ----------------------------------------------------------------------------
; stack_browse ?stack - the GENERIC one-doc-at-a-time stack iteration (the
; hsim twin of isim's stack-browse). It knows NOTHING about why the docs
; matter: it surfaces ?stack's top into @self's hand, one at a time, and
; re-files every doc the consumer marked handled. The CONSUMER task proposes
; this browse and processes each held doc it finds marked pending: either
; KEEP it ((bb-write ?doc browse-status kept) - it stays in hand and leaves
; the browse) or (bb-write ?doc browse-status handled) to send it back to
; the stack's bottom.
;
; CYCLE DETECTION is one marker on ?stack: browse-cycle-end = the FIRST doc
; buried this round. When it resurfaces as the top, every original doc has
; been seen - concluded. A round that buries nothing just empties the pile
; and concludes at the look. Doc tags clear as each doc SETTLES (kept or
; buried), so conclusion cleanup is two targeted keys on ?stack - no
; wildcard bb scan.
;
; ONE doc is in flight at a time. browse-inflight on ?stack holds the doc
; last lifted; "settled" is DERIVED - the doc's browse-status tag cleared
; (kept-accept and bury both clear it, and a doc a consumer DESTROYS settles
; by vanishing). The take and the conclusions wait on that, so a decided-but-
; not-yet-buried doc can never be stranded in hand by an early conclusion.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; The FIRST look, once per browse activation: peek (env truth, effects lane)
; and observe what the look shows. Seeing an empty stack concludes the round
; on the spot.
(npc-think stack_browse_look
  (task {@self stack_browse ?stack}:?browse)
  (task-prelude
    (tolerate (observe (spatial ?stack top /env)): ?top)
    (if (nothing ?top)
        (then (debug-print "SBR_EMPTY")
              (bb-clear ?stack browse-cycle-end)
              (bb-clear ?stack browse-inflight)
              (set-outcome ?browse succ)))))

; Mid-round: a pop leaves the exposed doc UNKNOWN again -> look again (and a
; pile emptied mid-round concludes here).
(npc-think stack_browse_relook
  (task {@self stack_browse ?stack}:?browse)
  (when (and (unknown (spatial ?stack top))
             (not (bb-has (bb-read ?stack browse-inflight) browse-status))))
  (effects
    (tolerate (observe (spatial ?stack top /env)): ?top)
    (if (nothing ?top)
        (then (debug-print "SBR_EMPTY")
              (bb-clear ?stack browse-cycle-end)
              (bb-clear ?stack browse-inflight)
              (set-outcome ?browse succ)))))

; The believed top, not the cycle marker, nothing in flight -> lift it. A ROLE
; (producer = the believed-top read), so the rung rides the wake plane instead
; of live when-evaluation every pulse; the producer yields one candidate or
; none (@unknown / _ = empty pool). The postlude stamps the doc pending (the
; consumer's cue) and latches the flight.
(npc-think stack_browse_take
  (task {@self stack_browse ?stack}:?browse)
  (role ?top (spatial ?stack top)
        (not (= ?top (bb-read ?stack browse-cycle-end)))
        (not (bb-has (bb-read ?stack browse-inflight) browse-status)))
  (effects
    (debug-print "SBR_TAKE doc=?top")
    (maintain-proposal {@self STACK_TAKE ?top ?stack}
        (postlude (bb-write ?top browse-status pending)
                  (bb-write ?stack browse-inflight ?top)))))

; The first buried doc back on top = the pile has cycled once - concluded.
(npc-think stack_browse_cycled
  (task {@self stack_browse ?stack}:?browse)
  (role ?top (spatial ?stack top)
        (= ?top (bb-read ?stack browse-cycle-end))
        (not (bb-has (bb-read ?stack browse-inflight) browse-status)))
  (effects
    (debug-print "SBR_CYCLED")
    (bb-clear ?stack browse-cycle-end)
    (bb-clear ?stack browse-inflight)
    (set-outcome ?browse succ)))

; The consumer KEPT the held doc -> it leaves the browse; clearing its tag IS
; the settle.
(npc-think stack_browse_accept
  (task {@self stack_browse ?stack}:?browse)
  (role ?doc [k document] (spatial @self hold)
        (= (bb-read ?doc browse-status) kept))
  (effects
    (debug-print "SBR_ACCEPT doc=?doc")
    (bb-clear ?doc browse-status)))

; The consumer marked the held doc handled -> back at the BOTTOM. The bury's
; postlude sets the cycle marker (first bury only); clearing the doc's tag IS
; the settle.
(npc-think stack_browse_return
  (task {@self stack_browse ?stack}:?browse)
  (role ?doc [k document] (spatial @self hold)
        (= (bb-read ?doc browse-status) handled))
  (effects
    (debug-print "SBR_RETURN doc=?doc")
    (maintain-proposal {@self STACK_BURY ?doc ?stack}
        (postlude (if (not (bb-has ?stack browse-cycle-end))
                      (then (bb-write ?stack browse-cycle-end ?doc)))
                  (bb-clear ?doc browse-status)))))
