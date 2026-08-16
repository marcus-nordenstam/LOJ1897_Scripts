; ----------------------------------------------------------------------------
; sporting_judge (npc-think) - the organiser's decision to DECLARE the meet winner.
; Split out of the old judge_meet_act (act_body_purification): choosing the victor is an
; argmax over the race_result beliefs the co-present racers minted into the organiser -
; that is deliberation, so it lives here; the observable declaration (honours + rivalrous
; anchors + scoreboard clear) is the dumb judge_declare_act (hold_meet_act.hs).
;
; open_meet_act summoned the field; the want_judge think holds the standing
; {@self judge_meet} goal while any race_result stands unjudged (sporting_event_think.hs).
; Each racer's race_act mints {?racer race_result <score> <sport>} into the organiser as
; he finishes (aux = the sport, so the declaration knows which contest it crowns).
; This think casts the current top scorer and proposes {@self JUDGE_DECLARE ?winner ?sport},
; so the proposal tracks the leader as stragglers report; once
; it wins the auction judge_declare_act declares that racer, and meet_judged clears the
; scoreboard, which (via want_judge) retracts the judge_meet goal.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think sporting_judge
  (goal {@self judge_meet})
  (role ?winner [k human]
                (believes {?winner race_result ? ?sport})
                (select (score (any {?winner race_result}).target) (policy argmax)))
  (utility 40)
  (effects (maintain-proposal {@self JUDGE_DECLARE ?winner ?sport})))

; Outcome twin of the declaration: every OTHER racer was positionally
; outcompeted -> the observable rivalrous outdo anchor (the loser's own
; narcissism scales the sting, in ms1); the scoreboard clears so next year's
; meet starts clean, which also closes this twin's own ?r2 gate. The days-since
; guard scopes the gate to the declaration's own day (an ended /succ declare
; persists as a memory - without the guard last year's declaration plus this
; year's first score would fire the twin before this year's winner is declared).
(npc-think meet_judged
  (role @self (believes {@self JUDGE_DECLARE ?winner ? /succ}))
  (role ?r2 {?r2 race_result ?})
  (when (< (days-since-last {@self JUDGE_DECLARE /ever}) 1))
  (effects
    (for-each ?rb (every {? race_result ?})
      (do
        ?rb.subject: ?r
        ?rb.target: ?p
        (if (not (= ?r ?winner))
            (then (incident-anchor ?winner outdo ?r)))
        (end-belief ?rb)))))
