; ----------------------------------------------------------------------------
; hold_meet (npc-ACT lane) - the organiser's two acts of the club meet, decomposed
; into a TRUE npc-POV contest (act_body_purification + telepathy purge). The old
; single act picked the victor by (attr ?victor assertiveness) and the grudge by
; (attr ?bested narcissism) - reading OTHER people's hidden traits. Now nobody reads
; a trait off anyone else: each competitor SELF-simulates his run (race_act.hs) and
; the outcome is OBSERVABLE (a race_result belief minted into the co-present
; organiser), which the organiser reads from his OWN mind to declare the winner.
;
;   open_meet_act (organiser): reads his club's SPORT + ROSTER (own documents) and
;     SUMMONS each co-present, living roster member - a told fact ({?m summoned_to_meet
;     <sport> <organiser>}), honest. Records his own {@self meet_sport <sport>}, which the
;     want_judge think reads to hold the judge goal (sporting_event_think.hs).
;   race_act (each competitor): runs from his OWN attrs, mints the result into the
;     organiser (race_act.hs).
;   judge_meet_act (organiser): argmaxes the winner from the race_result beliefs he
;     holds, mints {winner won <sport>}, and anchors {winner outdo <loser>} for every
;     other racer (a real positional outcome). The GRUDGE is appraisal-native: the
;     rivalrous_act ms1 reaction folds each loser's OWN narcissism, so the proud loser
;     nurses it and the placid one shrugs - computed in the loser's mind, not here.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; The organiser opens the meet: summon the co-present field and record the sport (the
; want_judge think holds the judge goal off it). The victor/grudge deliberation is GONE -
; this act reads no trait.
(npc-action open_meet_act
  (act {@self hold_meet_run})
  (duration 30)
  (act-effects
    ; The club's articles (goal focus) -> its kind + roster; then the sport, an EXACT
    ; lookup on the club kind (a kindless club holds no contest).
    (bind (goal-focus hold_meet) ?art)
    (read-doc-record [k articles_of_incorporation] ?art (kind ?club_kind) (register ?reg))
    (bind (lookup club_sports org_kind ?club_kind sport) ?sport)
    (if (is-kind ?sport)
      (then
        ; The organiser's OWN record that a meet is on (the judge think's self-gate).
        (begin-belief {@self meet_sport ?sport})
        ; Summon every co-present, living roster member: tell them the sport AND who
        ; runs it (aux = @self), so each racer knows whom to report his result to.
        (for-each-doc-record [k employee_register] ?reg (worker ?m)
          (if (and (alive ?m) (co-present @self ?m))
              (then (begin-belief ?m {?m summoned_to_meet ?sport @self}))))))
    (end-act {@self hold_meet_run})))

; The organiser declares the winner (act_body_purification: the DUMB act). The winner
; SELECTION is deliberation and lives in the sporting_judge think (sporting_judge_think.hs),
; which argmaxes the current top scorer from the race_result beliefs the racers minted into
; him and proposes {@self judge_declare ?winner}; this body just performs the declaration off
; the ?winner carried on its act-belief. No trait read - the winner is the highest OBSERVED
; performance, chosen in the think.
(npc-action judge_declare_act
  (act {@self judge_declare ?winner})
  (duration 30)
  (act-effects
    (bind (target {@self meet_sport}) ?sport)
    ; The victor takes the honours (minted into HIS mind - he was there, he is told).
    (begin-belief ?winner {?winner won ?sport})
    ; Every OTHER racer was positionally outcompeted -> the observable rivalrous anchor
    ; (auto-witnessed). The loser's own narcissism scales whether it stings, in ms1.
    ; The same pass clears the scoreboard so next year's meet starts clean.
    (for-each-belief {?r race_result ?}
      (do
        (bind (target {?r race_result}) ?p)
        (if (not (= ?r ?winner))
            (then (incident-anchor ?winner outdo ?r)))
        (end-belief {?r race_result ?p})))
    (end-belief {@self meet_sport ?sport})
    (end-act {@self judge_declare})))
