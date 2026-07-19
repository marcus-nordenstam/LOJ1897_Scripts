; ----------------------------------------------------------------------------
; deliberation_macros.hs - the deliberation OUTCOME dispatch + the two inline
; outlets (suicide / strive), composed from atomic ops. deliberate.hs picks a
; (pressure, action) winner via (select-joint ...); this turns that winner into
; its effect. Most actions mint a goal; suicide + strive resolve inline (they are
; not goals); a KILL whose wrongdoer is unreachable displaces onto a weaker innocent.
; ----------------------------------------------------------------------------

; despair = stress x (1 - contentment) - the self-belief reading behind the suicide gate.
(define-macro despair (?who)
  (* (target {?who stress}) (- 1 (target {?who contentment}))))

; The suicide outlet: the witnessed ideation is minted in a confidant's mind ALWAYS
; (the testimony trail); the act (death + the death_cause-suicide body-truth) only past
; the despair + withdrawal gate.
(define-macro resolve-suicide (?who)
  (do
    (bind (pick-confidant ?who) ?conf)
    (if (is-entity ?conf) (begin-belief ?conf {@self mention [k death_cause suicide]}))
    (if (and (>= (despair ?who) (suicide_despair_min))
             (>= (attr ?who withdrawal) (suicide_withdrawal_min)))
        (do (propagate-death ?who)
            (record-corpse-death ?who [k death_cause suicide])))))

; The strive outlet (benign envy): train for the rematch - stamp the practice marker
; (focus = the contested prize off the pressure's act cause) and discharge half the
; driving rivalry pressure. No goal.
(define-macro resolve-strive (?who ?pressure)
  (do
    (mark ?who [k practice] (pressure-prize ?pressure) (skill_practice_window_days))
    (discharge-pressure ?pressure 0.5)))

; Turn the deliberation winner into its effect. suicide / strive resolve inline; a KILL
; whose wrongdoer-focus is unreachable displaces onto a weaker innocent (re-routed to
; hurt, never a premeditated bystander kill); every other action mints its goal with
; the driving pressure pinned as /cause.
(define-macro resolve-deliberation (?action ?focus ?pressure)
  (if (= ?action suicide) (resolve-suicide @self)
  (if (= ?action strive)  (resolve-strive @self ?pressure)
  (if (= ?action kill)
      (do
        (bind (displace-victim @self ?focus (- 1 (inhibition))) ?sub)
        (if (is-entity ?sub)
            (begin-goal {@self hurt ?sub}   /cause ?pressure)
            (begin-goal {@self kill ?focus} /cause ?pressure)))
      (begin-goal {@self ?action ?focus} /cause ?pressure)))))

; (has-pressure ?actor): does ?actor hold ANY ongoing pressure belief? Folds the
; old C++ (has-pressure) op - its body was a first-ongoing {?actor pressure ?}
; bucket walk (has_any_ongoing_pressure), i.e. exactly this pattern existence.
(define-macro has-pressure (?actor)
  (believes {?actor pressure ?}))
