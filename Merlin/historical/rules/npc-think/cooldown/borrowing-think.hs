; ----------------------------------------------------------------------------
; borrowing - an F3.7 behaviour seed rule. Once in a while an adult takes on a
; debt to another adult, gaining an `owe` belief. The F3.5 wealth classifier
; counts distinct creditors: debt is the v1 poverty signal, so the debtors are
; exactly the population the deserving / undeserving_poor vertical classifies.
;
; ONE loan pursuit at a time: the decision is a monthly PULSE (cooldown +
; cease-after-fire) gated on holding NO TAKE_LOAN goal, so a landed roll mints
; exactly one goal and the next decision waits for its conclusion. The (not owe)
; filter keeps it one debt per creditor pair. The goal's END is owned by the
; twin outcome rules below (conventions): borrowing_done concludes it when the
; loan-call records the debt; borrowing_abandoned withdraws it if the creditor
; dies first (else the standing goal would block all future borrowing).
; The errand rungs (borrow_errand_think.hs) perform the goal; the loan-call act
; (borrow_errand_action.hs) records the {owe}.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think borrowing
  (cooldown 1 m)
  (rng-stream behaviour)
  (cease-after-fire)

  (role @self   (old_human @self))
  ; The home filter keeps the pursuit PERFORMABLE: the errand calls on the
  ; creditor at home, and there is no directory - an unknown address would
  ; strand the goal forever behind the no-goal gate.
  (role ?creditor (old_human ?creditor)
                  {?creditor home ?}
                  (not {@self owe ?creditor}))

  ; The borrow roll: low industriousness (less self-supporting) takes on debt
  ; more often. One evaluation round per cooldown period; the no-goal gate caps
  ; the round at one landed pursuit.
  (when (and (no-goal {@self TAKE_LOAN ?})
             (chance (* 0.005 (- 1.5 (attr @self industriousness))))))

  (utility errand)
  (effects (begin-goal {@self TAKE_LOAN ?creditor})))

; Outcome twin: the loan-call recorded the debt - the pursuit succeeded.
(npc-think borrowing_done
  (goal {@self TAKE_LOAN ?creditor})
  (role @self {@self owe ?creditor})
  (effects (end-goal {@self TAKE_LOAN ?creditor})))

; Outcome twin: the creditor is KNOWN dead - withdraw the pursuit. POSITIVE death
; knowledge only: a merely-decayed alive belief must not abandon the errand. The
; gate binds ?creditor, so the death test rides a (role @self ...) filter over that
; gate var (symmetric with borrowing_done's own-belief role above).
(npc-think borrowing_abandoned
  (goal {@self TAKE_LOAN ?creditor})
  (role @self {?creditor condition [k dead]})
  (effects (end-goal {@self TAKE_LOAN ?creditor})))
