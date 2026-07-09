; ----------------------------------------------------------------------------
; attend - the occasion ATTENDANCE act (occasion_ceremony_plan.md, Item 4).
;
; An npc-act in the three-stage intra-day lane shape (cf. the drinking lane). On the
; window in which an occasion's date lands, the appointment review has minted an
; attend goal {@self goal {@self attend <occ>}}; these intra-day events drain it:
;
;   attend_go     : hold the goal, it is the occasion's hour, not yet at the venue
;                   -> a (go) travel act to the occasion's venue.
;   attend_dwell  : hold the goal, it is the occasion's hour, AT the venue -> a
;                   dwell act. The dwell IS the attendance; co-presence (the
;                   location attr stamped on arrival) is what every other attendee
;                   - and the detective trail - reads.
;   attend_episode: the dwell completion (completion-only) - clears the goal so the
;                   desire does not re-fire, and records the attendance narrative.
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
; -> the (at-place ?venue) gate fails and the lane simply waits.
(hsim-npc-behaviour attend_go
  (short-term-think)
  (bind (target {@self goal {@self attend ?}}) ?occ)
  (when (and (has-goal attend)
             (bind {?occ venue ?venue})
             (attend-in-window @self)
             (not (at-place ?venue))))
  (utility (attend-utility @self))
  (effects (begin-act {@self go ?venue})))

(hsim-npc-behaviour attend_dwell
  (short-term-think)
  (bind (target {@self goal {@self attend ?}}) ?occ)
  (when (and (has-goal attend)
             (bind {?occ venue ?venue})
             (attend-in-window @self)
             (at-place ?venue)))
  (utility (attend-utility @self))
  (effects (begin-act {@self attend} (attend-minutes-left @self) attend_episode)))

(hsim-npc-behaviour attend_episode
  (on-completion)
  (effects
    ; If this was a WEDDING and the attendee is one of its principals, the
    ; marriage is made HERE, at the church, by who showed up: end the
    ; betrothal, spouse bond both sides, propagate (formalize-marriage). The
    ; second principal to arrive fails the not-married gate - idempotent.
    (bind (attend-occasion [k wedding]) ?wedding)
    (if (and (is-entity ?wedding)
             (believes {@self organize ?wedding})
             (not (is-married @self))
             (is-entity (target {@self fiancee})))
        (formalize-marriage (target {@self fiancee})))
    ; If the attendee is the HOST, appraise who came vs who was invited: a
    ; no-show's standing with the host degrades - snub -0.15 base, deepened
    ; +0.35 x prior warmth (a close friend's absence wounds more) - and the
    ; invited records close.
    (note-attendance @self 0.15 0.35)
    ; (The wedding MURDER needs no hook here: a crasher with a kill goal holds a
    ; fight goal from the melee routing, and kill_strike (fight.hs) outweighs
    ; every attend act the moment he is co-present with his rival.)
    (end-goal {@self attend})
    ))
