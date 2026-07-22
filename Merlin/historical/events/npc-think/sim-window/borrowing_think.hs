; ----------------------------------------------------------------------------
; borrowing - an F3.7 behaviour seed event. Once a year a share of adults take
; on a debt to another adult, gaining an `owe` belief. The F3.5 wealth
; classifier counts distinct creditors: debt is the v1 poverty signal, so the
; debtors are exactly the population the deserving / undeserving_poor vertical
; classifies. The (not (believes ...)) filter keeps it one debt per pair.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
; (relational: debtor + a non-self creditor, no co-presence), MONTHLY now, so the
; debtor (chance) base is /12 (0.06 -> 0.005) to hold the annual borrowing volume.
(npc-think borrowing
  (schedule cooldown 1 m)
  (rng-stream behaviour)

  (role @self   (old_human @self))
  (role ?creditor (old_human ?creditor)
                  (not (believes {@self owe ?creditor})))

  ; The borrow roll - an ONSET. (eval-until-hold) rolls it at the fire and LOCKS it
  ; once the goal holds, so the held re-check never re-rolls (it re-rolls each month
  ; until it lands). Low industriousness (less self-supporting) takes on debt more often.
  (when (eval-until-hold (chance (* 0.005 (- 1.5 (attr @self industriousness))))))

  ; MAINTENANCE: the decision OWNS the take_loan goal end to end. The ?creditor role's
  ; (not owe) filter is the CONTINUOUS completion gate - while @self owes this creditor
  ; nothing the goal stands; the moment take_loan_act records {@self owe ?creditor} the
  ; role drops and the cease-effects end the goal. The npc-action (borrow_errand.hs) sends
  ; the debtor to the creditor's home and records the {owe} there.
  (effects       (begin-goal {@self take_loan ?creditor}))
  (cease-effects (end-goal   {@self take_loan ?creditor})))
