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
;   hold_meet_go / hold_meet_dwell: while the goal stands, hold_meet_go walks him to
;     his clubhouse (articles-building; the generic enter chain does the travel) and
;     cedes on arrival; hold_meet_dwell, once he is inside, proposes the on-site
;     {@self hold_meet_run} act that open_meet_act drains (it summons the field).
;   compete: the COMPETITOR's half - a member the organiser summoned proposes his own
;     {@self race_run} act (race_act runs his leg from his own attributes).
;
; The SPORT is authored content read per club kind from tables/club_sports.hs;
; the roster is the employee_register the organiser legitimately holds - both
; read inside open_meet_act (hold_meet_act.hs), never here.
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

  ; MAINTENANCE: the annual decision OWNS the meet goal end to end. hold_meet_act mints no
  ; durable done-belief on @self (it records participated_in / won on the co-present MEMBERS),
  ; so the completion gate reads the organiser's OWN episodic meet memory: the {@self
  ; hold_meet_run} act-belief begun-at-commit / ended-at-completion (like gamble's play_game).
  ; While it has been a while since his last meet the standing goal holds; once hold_meet_act
  ; ends {@self hold_meet_run} days-since-last resets, the (when) drops, and the falling edge
  ; ends the goal. The yearly timer owns the annual cadence, so the day-threshold need only
  ; distinguish "just held" (0) from "a year on" (~365); 1 is the minimal such gate.
  (when (>= (days-since-last @self hold_meet_run) 1))

  ; Latch the standing meet goal, focused on the club's articles (recovered from @self's
  ; {?club record ?art} belief, exactly as club_joining / apprenticeship recover an org's
  ; articles).
  (effects       (begin-goal {@self hold_meet (target {?club record})}))
  (cease-effects (end-goal   {@self hold_meet (target {?club record})})))

; --- routing: get the organiser to his clubhouse, then propose the on-site act ---
; The clubhouse is the goal focus's premises (articles-building), role-free (recovered from
; the standing goal, never a scan). Two rungs, both gated on the standing {@self hold_meet}:
; hold_meet_go (maintenance) holds {@self enter ?clubhouse} while he is not yet inside (the
; generic enter chain does the travel) and ceases it on arrival; hold_meet_dwell (terminal),
; once he is inside, proposes {@self hold_meet_run} each decision point - the act open_meet_act
; drains and ends its own act-belief. When hold_meet ceases the standing goal, hold_meet_go
; loses its parent and retracts, and the dwell rung stops proposing.
(npc-think hold_meet_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self hold_meet})
  (when (and (articles-building (goal-focus hold_meet) ?clubhouse)
             (not (in-building ?clubhouse))))
  (utility 35)
  (effects       (begin-goal {@self enter ?clubhouse}))
  (cease-effects (end-goal   {@self enter ?clubhouse})))

(npc-think hold_meet_dwell
  (schedule always)
  (if-blocked hold)
  (goal {@self hold_meet})
  (when (and (articles-building (goal-focus hold_meet) ?clubhouse)
             (in-building ?clubhouse)))
  (utility 35)
  (effects (maintain-proposal {@self hold_meet_run})))

; --- the organiser OWNS the judge goal off his own meet_sport state ---------------
; open_meet_act (hold_meet_act.hs) records {@self meet_sport <sport>} when the meet
; opens and clears it when judge_declare_act declares the winner. While that record
; stands this MAINTENANCE think holds the standing {@self judge_meet} goal that
; sporting_judge reads (sporting_judge_think.hs) to pick + propose the winner; the
; falling edge - judge_declare_act ending meet_sport - retracts the goal. The act no
; longer mints or ends judge_meet (act_body_purification: acts run effects only).
(npc-think want_judge
  (schedule always)
  (role @self (believes {@self meet_sport ?}))
  (effects       (begin-goal {@self judge_meet}))
  (cease-effects (end-goal   {@self judge_meet})))

; --- the COMPETITOR's terminal: a summoned member proposes his own race act --------
; open_meet_act told this member {@self summoned_to_meet <sport> <organiser>}; while
; that summons stands he PROPOSES the {@self race_run} act each decision point (race_act
; drains it and ends the summons, so the propose stops once his leg is run). Utility above
; routine so the obligation to compete pulls him off idler errands for the one run.
(npc-think compete
  (schedule always)
  (role @self (believes {@self summoned_to_meet ?}))
  (utility 45)
  (effects (maintain-proposal {@self race_run})))
