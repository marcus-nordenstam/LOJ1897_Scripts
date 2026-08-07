; ----------------------------------------------------------------------------
; hold_meet (npc-ACT lane) - the organiser's two acts of the club meet, decomposed
; into a TRUE npc-POV contest (act_body_purification + telepathy purge). The old
; single act picked the victor by (attr ?victor assertiveness) and the grudge by
; (attr ?bested narcissism) - reading OTHER people's hidden traits. Now nobody reads
; a trait off anyone else: each competitor SELF-simulates his run (race_action.hs) and
; the outcome is OBSERVABLE (a race_result belief minted into the co-present
; organiser), which the organiser reads from his OWN mind to declare the winner.
;
;   open_meet_action (organiser): reads his club's SPORT + ROSTER (own documents) and
;     SUMMONS each co-present, living roster member - a told fact ({?m summoned_to_meet
;     <sport> <organiser>}), honest. Records his own {@self meet_sport <sport>}, which the
;     want_judge think reads to hold the judge goal (sporting_event_think.hs).
;   race_action (each competitor): runs from his OWN attrs, mints the result into the
;     organiser (race_action.hs).
;   judge_meet_action (organiser): argmaxes the winner from the race_result beliefs he
;     holds, mints {winner won <sport>}, and anchors {winner outdo <loser>} for every
;     other racer (a real positional outcome). The GRUDGE is appraisal-native: the
;     rivalrous_act ms1 reaction folds each loser's OWN narcissism, so the proud loser
;     nurses it and the placid one shrugs - computed in the loser's mind, not here.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; The organiser opens the meet: summon the co-present field and record the sport (the
; want_judge think holds the judge goal off it). The victor/grudge deliberation is GONE -
; this act reads no trait.
(npc-action {@self hold_meet_run ?art}
  (duration 30)
  (effects
    ; The club's articles (carried on the act-belief) -> its kind + roster; then the
    ; sport, an EXACT lookup on the club kind (a kindless club holds no contest).
    (read-doc-record [k articles_of_incorporation] ?art (kind ?club_kind) (register ?reg))
    (if (is-kind (lookup club_sports org_kind ?club_kind sport))
      (then
        (bind (lookup club_sports org_kind ?club_kind sport) ?sport)
        ; The organiser's OWN record that a meet is on (the judge think's self-gate).
        (begin-belief {@self meet_sport ?sport})
        ; Summon every co-present, living roster member: tell them the sport AND who
        ; runs it (aux = @self), so each racer knows whom to report his result to.
        (for-each-doc-record [k employee_register] ?reg (worker ?m)
          (if (and (alive ?m) (co-present @self ?m))
              (then (begin-belief ?m {?m summoned_to_meet ?sport @self}))))))
    (set-outcome {@self hold_meet_run} succ)))

; The organiser declares the winner (act_body_purification: the DUMB act). The winner
; SELECTION is deliberation and lives in the sporting_judge think (sporting_judge_think.hs),
; which argmaxes the current top scorer from the race_result beliefs the racers minted into
; him and proposes {@self judge_declare ?winner}; this body just performs the declaration off
; the ?winner carried on its act-belief. No trait read - the winner is the highest OBSERVED
; performance, chosen in the think.
(npc-action {@self judge_declare ?winner ?sport}
  (duration 30)
  (effects
    ; The victor takes the honours (minted into HIS mind - he was there, he is told).
    (begin-belief ?winner {?winner won ?sport})
    ; (the outdo anchors + scoreboard clearing are the meet_judged twin's -
    ;  sporting_judge_think.hs - off this declaration's /succ record.)
    (set-outcome {@self judge_declare} succ)))
