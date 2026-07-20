; ----------------------------------------------------------------------------
; sporting_event - the club ORGANISER's annual meet, the think + routing half.
; (The act half - the contest itself - lives in events/npc-act/hold_meet.hs.)
;
; Replaces the old zero-role world sweep (world-act/sports.hs + the C++
; run_effect_hold_sporting_events). No omniscient club/roster/jockey scan: the
; organiser is a real deliberating NPC who reasons from HIS OWN club beliefs and
; acts at HIS OWN clubhouse.
;
;   hold_meet (yearly timer): the club's founder/head resolves ONCE a year to
;     hold his club's meet. He role-casts his OWN club from the founder / record
;     beliefs he minted at found-club-seq (no scan) and latches a standing
;     {@self hold_meet <club-articles>} goal.
;   hold_meet_route (short-think): while the goal stands, walk him to his
;     clubhouse (articles-building) and, once there, latch the on-site
;     {@self hold_meet_run} act-goal that hold_meet.hs drains.
;
; The SPORT is authored content read per club kind from tables/club_sports.hs;
; the roster is the employee_register the organiser legitimately holds - both
; read inside the act (hold_meet.hs), never here.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; --- the annual decision to hold a meet (fires once, in June) ----------------
(npc-think hold_meet
  ; ANNUAL: a yearly timer latches the standing meet goal once per year. No cadence marker -
  ; the (schedule ...) is the cadence.
  (schedule cooldown 1 y)
  (if-blocked hold)
  (rng-stream behaviour)

  ; The organiser is the club's founder/head (an established adult). @self reads
  ; his OWN club object - a known org he founded ({?club founder @self} + the
  ; {?club record ?articles} handle are his own beliefs, minted at found-club-seq).
  ; [k org club] narrows to club orgs (a business he founded is not cast here).
  (role @self (old_human @self))
  (role ?club (known_org ?club)
              [k org club]
              (believes {?club founder @self}))

  ; Latch the standing meet goal, focused on the club's articles (recovered from
  ; @self's {?club record ?art} belief, exactly as club_joining / apprenticeship
  ; recover an org's articles). The yearly timer mints it once a year;
  ; (begin-goal) is idempotent, so an enumerated re-fire is a harmless no-op.
  (effects
    (begin-goal {@self hold_meet (target {?club record})})))

; --- routing: get the organiser to his clubhouse, then latch the on-site act ---
; The clubhouse is the goal focus's premises (articles-building), so the venue is
; role-free (recovered from the standing goal, never a scan). route-to-venue-then-act
; (macros/errand_macros.hs) holds a {@self go ?clubhouse} sub-goal until he is
; there, then latches {@self hold_meet_run} - the act-goal hold_meet.hs drains.
(npc-think hold_meet_route
  (short-term-think)
  (goal {@self hold_meet})
  (when (articles-building (goal-focus hold_meet) ?clubhouse))
  (utility 35)
  (cont-fire-effects
    (if (in-building ?clubhouse)
        (begin-goal {@self hold_meet_run})
        (excl-goal {@self enter ?clubhouse}))))
