; ----------------------------------------------------------------------------
; sporting_judge (npc-think) - the organiser's decision to DECLARE the meet winner.
; Split out of the old judge_meet_act (act_body_purification): choosing the victor is an
; argmax over the race-result beliefs the co-present racers minted into the organiser -
; that is deliberation, so it lives here; the observable declaration (honours) is the
; dumb judge_declare_act (JUDGE-DECLARE.hs).
;
; open_meet_act summoned the field; the want_judge think holds the standing
; {@self judge-meet} goal while any race-result stands unjudged (sporting_event_think.hs).
; Each racer's race_act mints {?racer race-result <score> <sport>} into the organiser as
; he finishes (aux = the sport, so the declaration knows which contest it crowns).
; This think casts the current top scorer and proposes {@self JUDGE-DECLARE ?winner ?sport},
; so the proposal tracks the leader as stragglers report; once
; it wins the auction judge_declare_act declares that racer, and meet_judged clears the
; scoreboard, which (via want_judge) retracts the judge-meet goal.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think sporting_judge
  (goal {@self judge-meet})
  (role ?winner [k human]
                {?winner race-result ? ?sport}
                (select (score (any {?winner race-result}).target) (policy argmax)))
  (effects (maintain-proposal {@self JUDGE-DECLARE ?winner ?sport})))

; Scoreboard clear: once the declaration is made, the organiser retires the
; race-result beliefs so next year's meet starts clean (which also closes the
; judge-meet goal via want_judge). The rivalrous outdo now rides the witnessed
; declaration in each LOSER's mind (outdone_at_meet), not an anchor minted from
; here. The days-since guard scopes the gate to the declaration's own day (an
; ended /succ declare persists as a memory - without it last year's declaration
; plus this year's first score would clear the board before this year's winner).
(npc-think meet_judged
  (role @self {@self JUDGE-DECLARE ? /succ})
  (role ?r2 {?r2 race-result ?})
  (when (< (days-since-last {@self JUDGE-DECLARE /ever}) 1))
  (effects
    (for-each ?rb-rel (every {? race-result ?})
      (end-belief ?rb-rel))))

; outdone_at_meet (npc-think, LOSER's mind). A racer who competed (his own ended
; RACE-RUN memory) and then WITNESSED another declared the meet victor construes
; {?winner outdo @self} - the rivalrous grudge rides the observed JUDGE-DECLARE, no
; anchor minted across minds. The sting is trait-gated: narcissism x assertiveness
; on a 0.15 floor (the retired roll_outdo_resentment); the dedup keeps one grudge
; per winner.
(npc-think outdone_at_meet
  (cooldown 1 m)
  (rng-stream incidents)
  ; The declaration @self witnessed binds the winner (its target). @self only holds
  ; declarations from meets he attended (the auto-witness drops the sport aux, so it
  ; is not bound here); pairing that with his own RACE-RUN memory means he competed
  ; at a meet where another was crowned.
  (role ?winner {?winner isa [k human], condition [k alive]}
                {? JUDGE-DECLARE ?winner}
                -{?winner outdo @self})
  (when (and (!= ?winner @self)
             ; @self competed at a meet (his own ended RACE-RUN memory).
             {@self RACE-RUN ? ? /succ /ever}
             (chance (+ 0.15 (* 0.85 (attr @self narcissism) (attr @self assertiveness))))))
  (effects
    (begin-belief {?winner outdo @self})))
