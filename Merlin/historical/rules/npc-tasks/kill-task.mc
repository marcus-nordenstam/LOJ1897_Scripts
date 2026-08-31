; ----------------------------------------------------------------------------
; kill - the killing task. The murder DRIVERS (crime_of_passion, betrayal_kill,
; covet_inheritance, rid_of_spouse, ambition, predation, conspiracy_adoption,
; clear_marriage) maintain-propose {@self kill ?victim} while their REASON (the
; grudge bond named on /caused_by) holds; the drive fades the moment the reason
; does, and drops when the victim dies. This task, once selected, is the METHOD
; DECIDER: it roulette-picks over kill_method_table and proposes the chosen killing
; sub-task (strangle / shoot / hire-assassin), which drives down to the physical
; blow (CHOKE / TRIGGER_FIREARM / SAY).
;
; No outcome twin: the drivers' maintain-conditions own the lifecycle (victim dead
; or reason gone -> the proposal drops), and the DEED's record is the killing
; action's own ended act-belief + its crime-ledger row - not this coordinator's.
; The method pick is ARGMAX (deterministic on trait / means), so it is STABLE across
; deliberations - a strong hand strangles, an armed weak hand shoots, a rich hand
; hires - and only switches if the means change (a firearm acquired). Maintain-
; proposing the winner retracts it automatically when this task drops.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(define-table kill_method_table
  (fields method              score-weight  score-eval)
  (record strangle            1             (if (>= (attr @self strength) 0.45) (then 1) (else 0.3)))
  (record shoot               0.9           (if (spatial [k firearm] space) (then 1) (else 0.4)))
  (record hire-assassin       0.5           (if (>= (coin-balance @self) 80) (then 1) (else 0))))

(npc-task {@self kill ?victim}:?kill-rel
  (tar human)
  (construed-act harm-act) (theme violent-to) (contradicts life)
  (facets reportable_crime blackmailable)
  (try
    (when -{?victim condition [k dead]})
    (select-joint
      (table kill_method_table)
      (bind method ?method)
      (bind score-weight ?weight)
      (bind score-eval ?eval)
      (score (* ?weight (eval ?eval)))
      (policy argmax))
    (utility survival)
    (effects (maintain-proposal {@self ?method ?victim}))))
