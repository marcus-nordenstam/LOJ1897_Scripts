; ----------------------------------------------------------------------------
; attend (think lane) - the go/dwell think rungs of the occasion ATTENDANCE lane
; (occasion_ceremony_plan.md, Item 4). The attendance act lives in npc-act/attend.hs.
;
;   attend_go     : hold the goal, it is the occasion's hour, not yet at the venue
;                   -> push the attend utility onto the goal + maintain a (go)
;                   sub-goal to the occasion's venue (the go rung promotes).
;   attend_dwell  : hold the goal, it is the occasion's hour, AT the venue -> push
;                   the utility so {@self attend}, now the leaf, promotes to
;                   attend_act.
;
; SEPARATION OF CONCERNS: (when ...) gates TIMING - (attend-in-window @self) reads
; the occasion's own `hours` belief, so the day's work / rest / leisure lanes own
; the rest of the day and the gathering only pulls people during its stated hours
; (no presumed time of day). (utility ...) decides DESIRABILITY - whether to go at
; all: MAX for the host / co-host (a principal always attends their own occasion /
; wedding), warmth-scaled for a guest (the indifferent or feuding decline), 0 for
; the bedridden. The two are not conflated.
;
; The venue is resolved from the occasion the actor's attend goal points at; an
; unresolved / venue-less occasion yields k_fail, so attend_go emits nothing and
; the other lanes win (the goal simply waits, then expires next window).
; ----------------------------------------------------------------------------

; The venue is a pure own-belief chain: the occasion is the focus of @self's
; attend goal ({@self goal {@self attend ?occ}}), and the occasion carries a
; {?occ venue ?venue} belief - both read from the NPC's OWN mind (mental, no
; C++ venue op, no scan). A goal-less / venue-less occasion leaves ?venue unbound
; -> the (in-building ?venue) gate fails and the lane simply waits.
; APPROACH - not yet at the occasion's venue: push the attend utility onto the
; goal (so its go sub-goal inherits the drive) and head there. attend is a
; non-leaf while {@self go ?venue} stands, so the go rung promotes.
(npc-think attend_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self attend ?occ})
  (when (and (believes {?occ venue ?venue})
             (attend-in-window @self)
             (not (in-building ?venue))))
  (utility (attend-utility @self))
  (effects       (begin-goal {@self enter ?venue}))
  (cease-effects (end-goal   {@self enter ?venue})))

; TERMINAL step (act_body_purification): at the venue in the window, the attendance act is now
; PROPOSED ({@self attend}), not auto-promoted by a self-begun leaf goal. The proposal carries
; the attend desirability (attend-utility) and inherits its endeavour from the {@self attend ?occ}
; goal it /causes (via the (goal ...) gate). Reactive (schedule always): re-proposes each decision
; point while the actor stands at the venue in the window.
(npc-think attend_dwell
  (schedule always)
  (goal {@self attend ?occ})
  (when (and (believes {?occ venue ?venue})
             (attend-in-window @self)
             (in-building ?venue)))
  (utility (attend-utility @self))
  (effects (maintain-proposal {@self attend})))
