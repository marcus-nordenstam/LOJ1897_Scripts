; ----------------------------------------------------------------------------
; possession_macros.hs - "does @self hold X" as a belief query.
;
; Possession is DERIVED from the perceived skeleton, not the env attr: @self holds
; ?thing iff one of @self's hands controls it. `hand` is the perceived grouping of
; the two hands ({@self hand <left/right>}) and `control` the perceived hand-holds-
; item belief ({hand control item}) - both hsim-perceptible. The hand.control CHAIN
; LABEL walks both in one existence test (2 hands, so cheap), matching ?thing by
; is-a (a [k] or bound kind) or identity (a bound object).
;
; Supersedes the removed C++ (controls ...) op, which read right_hand.control[] (env
; ground truth) - telepathy-honest only because it was @self, but an attr read in a
; deliberation lane. This reads the mind's own perceived mirror.
; ----------------------------------------------------------------------------

; (control ?thing): does @self hold ?thing - a specific object, or any item of the
; kind ?thing (e.g. (control ?means) is "am I holding the required tool")?
(define-macro control (?thing)
  (believes {@self hand.control ?thing}))
