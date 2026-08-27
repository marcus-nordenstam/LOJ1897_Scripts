; ----------------------------------------------------------------------------
; combat_macros.hs - the shared per-blow physics for STRIKE (combat_actions.hs). The
; roll + wound dispatch lives inline in the action; what stays here is the two tunables
; and the fatal physics (kill-blow). blame lives on the driving TASK / the runtime-blame
; gate, never on the neutral blow.
; ----------------------------------------------------------------------------

; A whiffing attacker is easier to slip: a clean miss posts `whiffed` on the
; attacker (publicly observable), read by the flee roll as a recent-clumsiness bonus.
(define-macro whiff_ttl_cycles () 3)

; A sustained kill-assault finally tells: a LANDED-but-non-fatal kill blow succumbs
; with this per-blow probability (the bleed-out analogue the dead bleed columns modelled).
(define-macro blow_succumb_prob () 0.25)

; (kill-blow ?foe ?method): the fatal physics - the crime-ledger row (goal kill, task
; the specific verb), the objective violent death_cause on the corpse, then settle-death
; (world settlement + die - NO telepathy; witnesses learn via observation, absentees via
; the learn_of_death keystone). ?method is the striking verb literal.
(define-macro kill-blow (?foe ?method)
  (do
    (crime-ledger-append @self ?foe ?method kill @u @u)
    (record-corpse-death ?foe [k death_cause violence])
    (settle-death ?foe)))
