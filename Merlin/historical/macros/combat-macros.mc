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
; the specific verb), the objective violent death-cause on the corpse, then settle-death
; (world settlement + die - NO telepathy; witnesses learn via observation, absentees via
; the learn_of_death keystone). ?method is the striking verb literal.
; yield-evidence - the forensic trace a blow leaves on the body. ?site is the
; body-part kind struck; ?blemish a leaf of the blemish taxonomy (Objects.mon:
; wound / stain / mark). Written to the struck part's `blemishes` attr, which is
; /obs + auto-percept, so anyone who looks at the body reads it - that is the whole
; evidence channel. A body with no such part (or a part already carrying the same
; leaf, since the array is a SET) is a no-op.
(define-macro yield-evidence (?ye-target ?ye-site ?ye-blemish)
  (for-each ?ye-part (spatial ?ye-target parts ?ye-site /env) /limit 1
    (add-attr-item ?ye-part blemishes ?ye-blemish)))

(define-macro kill-blow (?foe ?method)
  (do
    (crime-ledger-append @self ?foe ?method kill @u @u)
    (set-attr ?foe death-cause [k death-cause violence])
    (settle-death ?foe)))
