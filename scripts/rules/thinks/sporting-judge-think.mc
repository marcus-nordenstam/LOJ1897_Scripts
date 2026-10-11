; ----------------------------------------------------------------------------
; sporting-judge - the meet's scoreboard: once the organiser has declared the winner
; (JUDGE-DECLARE) he clears it, and each loser who raced takes the winner's outdo.
; ----------------------------------------------------------------------------

; Scoreboard clear: once the declaration is made, the organiser retires the
; race-result beliefs so next year's meet starts clean. The rivalrous outdo now rides the witnessed
; declaration in each LOSER's mind (outdone-at-meet), not an anchor minted from
; here. The days-since guard scopes the gate to the declaration's own day (an
; ended /succ declare persists as a memory - without it last year's declaration
; plus this year's first score would clear the board before this year's winner).
(think meet-judged
  (role @self {@self JUDGE-DECLARE ? /succ}
    (role ?r2 {?r2 race-result ?}
      (when (< (days-since-last {@self JUDGE-DECLARE /ever}) 1))
      (effects
        (for-each ?race-result (every {? race-result ?})
          (end-belief ?race-result))))))

; outdone-at-meet (think, LOSER's mind). A racer who competed (his own ended
; RACE-RUN memory) and then WITNESSED another declared the meet victor construes
; {?winner outdo @self} - the rivalrous grudge rides the observed JUDGE-DECLARE, no
; anchor minted across minds. The sting is trait-gated: narcissism x assertiveness
; on a 0.15 floor (the retired roll_outdo_resentment); the dedup keeps one grudge
; per winner.
(think outdone-at-meet
  (cooldown 1 m try-once)
  (rng-stream incidents)
  ; The declaration @self witnessed binds the winner (its target). @self only holds
  ; declarations from meets he attended (the auto-witness drops the sport aux, so it
  ; is not bound here); pairing that with his own RACE-RUN memory means he competed
  ; at a meet where another was crowned.
  (role @self {@self narcissism ?narcissism}
              {@self assertiveness ?assertiveness}
    (role ?winner {?winner isa [k human], condition [k alive]}
                  {? JUDGE-DECLARE ?winner}
                  -{?winner outdo @self}
      (when (and (!= ?winner @self)
                 ; @self competed at a meet (his own ended RACE-RUN memory).
                 {@self RACE-RUN ? ? /succ /ever}
                 (chance (+ 0.15 (* 0.85 ?narcissism ?assertiveness)))))
      (effects
        (begin-belief {?winner outdo @self})))))
