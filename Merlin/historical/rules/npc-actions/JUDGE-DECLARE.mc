; ----------------------------------------------------------------------------
; judge_declare (npc-ACT) - the organiser's closing act of the club meet
; (act_body_purification: the DUMB act). The winner SELECTION is deliberation and
; lives in the sporting_judge think (sporting_judge_think.hs), which argmaxes the
; current top scorer from the race-result beliefs the racers minted into him
; (RACE_RUN.hs) and proposes {@self JUDGE_DECLARE ?winner}; this body just performs
; the declaration off the ?winner carried on its act-belief. No trait read - the
; winner is the highest OBSERVED performance, chosen in the think.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-action {@self JUDGE_DECLARE ?winner ?sport}
  (track-skill-level [k officiating])
  ; (obs): the declaration is made to the assembled - co-present racers WITNESS
  ; {@self JUDGE_DECLARE ?winner ?sport}, which is how a losing racer learns the
  ; victor and construes the outdo (outdone_at_meet, sporting_judge_think.hs).
  (obs) (duration 30)
  (effects
    ; The victor takes the honours (minted into HIS mind - he is the act's target,
    ; excluded from the bystander auto-witness, so he is told explicitly here).
    (begin-belief ?winner {?winner win ?sport})
    ; (the scoreboard clearing is the meet_judged twin's - sporting_judge_think.hs
    ;  - off this declaration's /succ record.)
    (set-outcome {@self JUDGE_DECLARE} /succ)))
