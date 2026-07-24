; ----------------------------------------------------------------------------
; attend (act lane) - the occasion ATTENDANCE act (occasion_ceremony_plan.md,
; Item 4). The go/dwell think rungs live in npc-think/attend.hs.
;
; On the window in which an occasion's date lands, the appointment review has minted
; an attend goal {@self goal {@self attend <occ>}}; the intra-day think rungs drain
; it and promote:
;
;   attend_action : the attendance dwell act. The begun-then-ended {@self attend}
;                   act-belief IS the attendance; co-presence (the location attr
;                   stamped on arrival) is what every other attendee - and the
;                   detective trail - reads. Its completion makes any wedding,
;                   appraises no-shows, and clears the goal.
; ----------------------------------------------------------------------------

; The attendance dwell: the begun-then-ended {@self attend} act-belief IS the
; attendance (co-presence at the venue is what every other attendee + the
; detective trail reads). Its completion makes a wedding, appraises no-shows,
; and clears the goal.
(npc-action {@self attend}
  (duration (attend-minutes-left @self))
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
        (then
          ; Bind the betrothed BEFORE formalize-marriage ends the fiancee belief.
          (bind {@self fiancee ?betrothed})
          (formalize-marriage ?betrothed)
          ; Announce the marriage to the co-present wedding party (the SAY they hear
          ; and adopt). Replaces announce_couple_to_guests' fiat spouse-writes; the
          ; wider circle learns via gossip (spouse is a gossip label).
          (tell {@self spouse ?betrothed})))
    ; If the attendee is the HOST, appraise who came vs who was invited: a
    ; no-show's standing with the host degrades - snub -0.15 base, deepened
    ; +0.35 x prior warmth (a close friend's absence wounds more) - and the
    ; invited records close.
    (note-attendance @self 0.15 0.35)
    ; (The wedding MURDER needs no hook here: a crasher with a kill goal holds a
    ; fight goal from the melee routing, and kill_strike (fight.hs) outweighs
    ; every attend act the moment he is co-present with his rival.)
    (set-outcome {@self attend} succ)
    ))
