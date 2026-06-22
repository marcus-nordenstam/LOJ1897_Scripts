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

(hsim-event attend_go
  (intra-day)
  (nl   "@self sets out for a gathering")
  (let ((?venue (attend-venue @self)))
    (when (and (has-goal attend)
               (attend-in-window @self)
               (not (at-place ?venue))))
    (utility (attend-utility @self))
    (effects (go @self ?venue))))

(hsim-event attend_dwell
  (intra-day)
  (nl   "@self attends a gathering")
  (let ((?venue (attend-venue @self)))
    (when (and (has-goal attend)
               (attend-in-window @self)
               (at-place ?venue)))
    (utility (attend-utility @self))
    (effects (act attend_episode (attend-minutes-left @self)))))

(hsim-event attend_episode
  (schedule (completion-only))
  (nl   "@self has attended a gathering")
  (effects
    ; If this was a WEDDING and the attendee is a principal, the marriage is made
    ; here, at the church, by who showed up (no-op for any other occasion).
    (formalize-wedding @self)
    ; If the attendee is the HOST, appraise who came vs who was invited: a no-show's
    ; standing with the host degrades (Item 6), and the invited records close.
    (note-attendance @self)
    ; The wedding-MURDER terminal: a jealous ex who crashed the occasion and carries
    ; a kill goal strikes his rival if present (no-op for the ordinary guest).
    (strike-at-occasion @self)
    (clear-goal @self attend)
    (log _attend_episode @self)))
