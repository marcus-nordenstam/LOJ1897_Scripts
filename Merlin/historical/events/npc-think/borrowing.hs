; ----------------------------------------------------------------------------
; borrowing - an F3.7 behaviour seed event. Once a year a share of adults take
; on a debt to another adult, gaining an `owe` belief. The F3.5 wealth
; classifier counts distinct creditors: debt is the v1 poverty signal, so the
; debtors are exactly the population the deserving / undeserving_poor vertical
; classifies. The (not (believes ...)) filter keeps it one debt per pair.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
; (relational: debtor + a non-self creditor, no co-presence), MONTHLY now, so the
; debtor (chance) base is /12 (0.06 -> 0.005) to hold the annual borrowing volume.
(hsim-npc-behaviour borrowing
  (long-term-think)
  (rng-stream behaviour)

  (role @self   (old_human @self))
  (role ?creditor (old_human ?creditor)
                  (not (= ?creditor @self))
                  (not (believes {@self owe ?creditor})))

  ; The borrow roll - moved out of the @self role (a (chance)/(attr) gate is
  ; non-belief, so it lives in (when), not the role). Low industriousness (less
  ; self-supporting) takes on debt more often.
  (when (chance (* 0.005 (- 1.5 (attr @self industriousness)))))

  ; SPLIT (Item 5): the npc-think - the decision to borrow. It mints {@self goal
  ; {@self borrow ?creditor}}; the npc-act (borrow_errand.hs) sends the debtor to
  ; the creditor's home and the completion records the {owe} there. (goal) is
  ; idempotent, so re-rolling while the goal stands is a no-op.
  (effects
    (begin-goal {@self take_loan ?creditor})))
