; ----------------------------------------------------------------------------
; perpetration_macros.hs - the EVENT-IZED perpetration terminal dispatch + terminal
; bodies, composed from atomic ops (the Phase 3(c) terminal decomposition).
;
; attempt_nonlethal.hs picks ONE standing goal whose terminal is event-ized (via
; (select-joint (over-goals ...) (table perpetration_terminals) ...)); this turns
; that winner into its act. Each terminal body is a .hs sequence of general atomic
; ops with the ontological labels/kinds as .hs literals - no term hardcoded in C++.
;
; Growing this as terminals move over: add the terminal's macro + a dispatch arm +
; a perpetration_terminals row + remove the goal's C++ skip in perpetration.cc.
; ----------------------------------------------------------------------------

; pay_off terminal (bribe goal): the mint-only shape - the band-5 act anchor
; {@self offer_bribe <victim>}, the driving pressure discharged (acting on the
; grievance releases it, so it does not re-deliberate the bribe monthly), the goal
; ended, and the crime-ledger row (task offer_bribe, goal bribe). No yields, no
; instrument, no cross-mind effect - a bribe is a private cash transfer.
(define-macro terminal-pay-off (?victim ?goal)
  (do
    (begin-belief {@self offer_bribe ?victim})
    (bind (driving-pressure-of-goal ?goal) ?pressure)
    (discharge-pressure ?pressure 0.75)
    (end-goal {@self bribe})
    (crime-ledger-append @self ?victim offer_bribe bribe @fail @fail)))

; Dispatch the select-joint winner (?terminal from the perpetration_terminals row)
; to its terminal body. ONE arm per event-ized terminal; the C++ generative loop
; still owns every terminal not listed here (and skips this goal, so no double-fire).
(define-macro resolve-perpetration-terminal (?terminal ?victim ?action ?goal)
  (if (= ?terminal pay_off) (terminal-pay-off ?victim ?goal)))
