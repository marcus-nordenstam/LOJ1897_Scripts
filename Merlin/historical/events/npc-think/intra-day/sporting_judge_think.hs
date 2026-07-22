; ----------------------------------------------------------------------------
; sporting_judge (npc-think) - the organiser's decision to DECLARE the meet winner.
; Split out of the old judge_meet_act (act_body_purification): choosing the victor is an
; argmax over the race_result beliefs the co-present racers minted into the organiser -
; that is deliberation, so it lives here; the observable declaration (honours + rivalrous
; anchors + scoreboard clear) is the dumb judge_declare_act (hold_meet_act.hs).
;
; open_meet_act recorded {@self meet_sport <sport>} and summoned the field; the want_judge
; think holds the standing {@self judge_meet} goal off that record (sporting_event_think.hs).
; Each racer's race_act mints {?racer race_result <score>} into the organiser as he finishes.
; On each such landing this think re-casts the current top scorer and re-proposes
; {@self judge_declare ?winner}, so the proposal tracks the leader as stragglers report; once
; it wins the auction judge_declare_act declares that racer and clears meet_sport, whose
; falling edge (via want_judge) retracts the judge_meet goal.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think sporting_judge
  (schedule on-changed)
  (goal {@self judge_meet})
  (role ?winner [k human]
                (believes {?winner race_result ?})
                (select (score (target {?winner race_result})) (policy argmax)))
  (utility 40)
  (effects (maintain-proposal {@self judge_declare ?winner})))
