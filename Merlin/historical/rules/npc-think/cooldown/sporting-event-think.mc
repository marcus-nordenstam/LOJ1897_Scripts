; ----------------------------------------------------------------------------
; sporting_event - the club ORGANISER's annual meet, the think + routing half.
; (The act half - the contest itself - lives in rules/npc-act/hold_meet.hs.)
;
; No omniscient club/roster/jockey scan: the organiser is a real deliberating NPC
; who reasons from HIS OWN club beliefs and acts at HIS OWN clubhouse.
;
;   hold_meet (yearly timer): the club's founder/head resolves ONCE a year to
;     hold his club's meet. He role-casts his OWN club from the founder / record
;     beliefs he minted at found-club-seq (no scan) and latches a standing
;     {@self hold_meet <club-articles>} goal.
;   hold_meet_go / hold_meet_dwell: while the goal stands, hold_meet_go walks him to
;     his clubhouse (articles-building; the generic enter chain does the travel) and
;     cedes on arrival; hold_meet_dwell, once he is inside, proposes the on-site
;     {@self HOLD_MEET_RUN} act that open_meet_act drains (it summons the field).
;   compete: the COMPETITOR's half - a member the organiser summoned proposes his own
;     {@self RACE_RUN} act (race_act runs his leg from his own attributes).
;
; The SPORT is authored content read per club kind from tables/club_sports.hs;
; the roster is the employee_register the organiser legitimately holds - both
; read inside open_meet_act (hold_meet_act.hs), never here.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

; --- the annual decision to hold a meet (fires once, in June) ----------------
(npc-think hold_meet
  ; ANNUAL: a yearly timer latches the standing meet goal once per year.
  (cooldown 1 y)
  (rng-stream behaviour)

  ; The organiser is the club's founder/head (an established adult). @self reads
  ; his OWN club object - a known org he founded ({?club founder @self} + the
  ; {?club record ?articles} handle are his own beliefs, minted at found-club-seq).
  ; [k org club] narrows to club orgs (a business he founded is not cast here).
  (role @self (old_human @self))
  (role ?club (known_org ?club)
              [k org club]
              {?club founder @self})

  ; MAINTENANCE: the annual decision OWNS the meet goal end to end. hold_meet_act mints no
  ; durable done-belief on @self (it records win on the co-present winner only),
  ; so the completion gate reads the organiser's OWN episodic meet memory: the {@self
  ; hold_meet_run} act-belief begun-at-commit / ended-at-completion (like gamble's play_game).
  ; While it has been a while since his last meet the standing goal holds; once hold_meet_act
  ; ends {@self HOLD_MEET_RUN} days-since-last resets, the (when) drops, and the goal ends.
  ; The yearly timer owns the annual cadence, so the day-threshold need only
  ; distinguish "just held" (0) from "a year on" (~365); 1 is the minimal such gate.
  (when (>= (days-since-last {@self HOLD_MEET_RUN /ever}) 1))

  ; Latch the standing meet goal, focused on the club's articles (recovered from @self's
  ; {?club record ?art} belief, exactly as club_joining / apprenticeship recover an org's
  ; articles).
  (utility duty)
  (effects       (begin-goal {@self hold_meet (any {?club record}).target}))
  (cease-effects (end-goal   {@self hold_meet (any {?club record}).target})))
