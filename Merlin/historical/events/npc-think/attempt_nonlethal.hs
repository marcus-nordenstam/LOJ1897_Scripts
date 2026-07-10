; ----------------------------------------------------------------------------
; attempt_nonlethal.hs - the EVENT-IZED perpetration driver for goals whose terminal
; has moved to .hs (the Phase 3(c) terminal decomposition). Sibling of attempt_harm
; (the C++ generative-perpetration event, which still owns every terminal NOT yet
; event-ized - including all kill / steal / place-lane fires).
;
; A normal (long-term-think): fires per-NPC at the window-start pass. It crosses the
; actor's standing goals with the perpetration_terminals metadata table via the joint
; kernel (select-joint (over-goals ?action ?victim ?goal) (table ...) ...), scoring a
; pair 1 only when the goal's action matches the row's action - so it picks ONE
; standing goal whose terminal is event-ized, then the resolve-perpetration-terminal
; macro runs that terminal's .hs body. No matching goal -> the select-joint binds
; nothing and the event no-fires.
;
; Today the only event-ized terminal is pay_off (bribe); attempt_harm.cc skips bribe
; goals so they fire here instead (no double-fire).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour attempt_nonlethal
  (long-term-think)
  (rng-stream perpetration)

  (role @self (any_human @self))

  ; Cheap early-out: only goal-holders run the (joint) reduction.
  (when (> (count-beliefs @self goal) 0))

  ; Pick ONE standing goal whose terminal has moved to .hs. ?action = the goal's
  ; inner action label, ?victim = its target, ?goal = the outer goal belief (the
  ; discharge / provenance handle). A pair scores 1 only when the goal action equals
  ; the row action, so an actor with no event-ized goal binds nothing (no fire).
  (select-joint
    (over-goals ?action ?victim ?goal)
    (table perpetration_terminals)
    (bind action ?row_action)
    (bind terminal ?terminal)
    (score (if (= ?action ?row_action) 1 0))
    (policy weighted))

  (effects
    (resolve-perpetration-terminal ?terminal ?victim ?action ?goal)))
