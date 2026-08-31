; ----------------------------------------------------------------------------
; sporting_event - the club ORGANISER's annual meet, the think + routing half.
; (The act half - the contest itself - lives in rules/npc-act/hold-meet.hs.)
;
; Replaces the old zero-role world sweep (world-act/sports.hs + the C++
; run_effect_hold_sporting_events). No omniscient club/roster/jockey scan: the
; organiser is a real deliberating NPC who reasons from HIS OWN club beliefs and
; acts at HIS OWN clubhouse.
;
;   hold-meet (yearly timer): the club's founder/head resolves ONCE a year to
;     hold his club's meet. He role-casts his OWN club from the founder / record
;     beliefs he minted at found-club-seq (no scan) and latches a standing
;     {@self hold-meet <club-articles>} goal.
;   hold_meet_go / hold_meet_dwell: while the goal stands, hold_meet_go walks him to
;     his clubhouse (articles-building; the generic enter chain does the travel) and
;     cedes on arrival; hold_meet_dwell, once he is inside, proposes the on-site
;     {@self HOLD_MEET_RUN} act that open_meet_act drains (it summons the field).
;   compete: the COMPETITOR's half - a member the organiser summoned proposes his own
;     {@self RACE_RUN} act (race_act runs his leg from his own attributes).
;
; The SPORT is authored content read per club kind from tables/club_sports.hs;
; the roster is the employee-register the organiser legitimately holds - both
; read inside open_meet_act (hold_meet_act.hs), never here.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

; --- routing: get the organiser to his clubhouse, then propose the on-site act ---
; The clubhouse is the goal focus's premises (articles-building), role-free (recovered from
; the standing goal, never a scan). Two rungs, both gated on the standing {@self hold-meet}:
; hold_meet_go (maintenance) holds {@self enter ?clubhouse} while he is not yet inside (the
; generic enter chain does the travel) and ceases it on arrival; hold_meet_dwell (terminal),
; once he is inside, proposes {@self HOLD_MEET_RUN} each env-cycle - the act open_meet_act
; drains and ends its own act-belief. When hold-meet ceases the standing goal, hold_meet_go
; loses its parent and retracts, and the dwell rung stops proposing.
(npc-think hold_meet_go
  (goal {@self hold-meet ?art})
  (when (and (articles-building ?art ?clubhouse)
             (not (spatial @self building ?clubhouse))))
  (effects (maintain-proposal {@self enter ?clubhouse})))

(npc-think hold_meet_dwell
  (goal {@self hold-meet ?art})
  (when (and (articles-building ?art ?clubhouse)
             (spatial @self building ?clubhouse)))
  (effects (maintain-proposal {@self HOLD_MEET_RUN ?art})))

; --- the organiser OWNS the judge goal off the scoreboard he holds ----------------
; Each racer's race_act mints {?racer race-result <score> <sport>} into the
; co-present organiser. While any such score stands unjudged this MAINTENANCE
; think holds the standing {@self judge-meet} goal that sporting_judge reads
; (sporting_judge_think.hs) to pick + propose the winner; meet_judged clearing
; the scoreboard then retracts the goal. The days-since guard bars a straggler
; score (a racer still running when the winner was declared) from re-opening
; the judging the same day.
(npc-think want_judge
  (role ?racer {?racer race-result ?})
  (when (>= (days-since-last {@self JUDGE_DECLARE /ever}) 1))
  (utility want)
  (effects       (begin-goal {@self judge-meet}))
  (cease-effects (end-goal   {@self judge-meet})))

; --- the COMPETITOR's terminal: a summoned member proposes his own race act --------
; open_meet_act told this member {?judge summon @self /aux ?sport}; while that
; ticket stands he PROPOSES the {@self RACE_RUN} act each env-cycle (race_act
; drains it and ends his copy of the summons, so the propose stops once his leg
; is run). Utility above routine so the obligation to compete pulls him off
; idler errands for the one run.
(npc-think compete
  (role ?judge {?judge summon @self ?sport})
  (utility want)
  (effects (maintain-proposal {@self RACE_RUN ?sport ?judge})))
