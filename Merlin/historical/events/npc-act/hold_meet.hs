; ----------------------------------------------------------------------------
; hold_meet - the npc-ACT half of the club meet (the contest itself).
;
; The routing think (npc-think/sporting_event.hs) walked the organiser to his
; clubhouse and latched {@self hold_meet_run}; that act-goal promotes THIS body.
; The organiser reads his club's SPORT (tables/club_sports.hs, by the club kind
; on the articles he holds) and its ROSTER (the employee_register the articles
; name - a document he legitimately holds, not a world scan), then:
;   - every co-present, living roster member remembers competing
;     ({?m participated_in <sport>}, minted in the competitor's own mind - the
;     canonical mint-on-a-co-present-other, cf. affair.hs / advantageous_match.hs);
;   - the VICTOR (a co-present competitor, weighted by observable vigour) takes
;     the honours ({?victor won <sport>});
;   - ONE bested rival may resent the win and record the {victor outdo bested}
;     contest anchor (the sporting_rivalry seed the rivalrous-act cascade reads).
;
; ROBUSTNESS: @self is the FIRST role so the completion path presets it; ?victor
; and ?bested are co-present-only (their score zeroes out anyone not in the room),
; and neither excludes the other at the ROLE level - the self / victor exclusions
; live in the effect guards. So the act fires whenever >=1 competitor is present
; and always ends both act-belief and goal; a meet no member attends simply holds
; no contest (the participated walk is empty) and still clears the goal on a later
; cycle when someone is there. No omniscient roster/jockey scan and no hidden
; `practice` marker (that was telepathy): the victor is read from OBSERVABLE
; assertiveness + the roulette draw.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-act hold_meet_act
  ; @self first (the completion path presets role-0 to the actor); the light gate.
  (role @self (grown @self))

  ; The VICTOR: a co-present competitor, drawn weighted by observable vigour
  ; (assertiveness + a base so anyone present can win). co-present rides the SCORE
  ; (not a role filter - positional co-presence is not object-cacheable), so a
  ; town-known human who is NOT in the room scores 0 and is never drawn.
  (role ?victor [k human]
                (not (= ?victor @self))
                (select (score (* (co-present @self ?victor)
                                  (+ 0.15 (attr ?victor assertiveness))))
                        (policy roulette)))

  ; ONE bested rival: a co-present competitor, drawn uniformly among those present
  ; (score = co-presence). Whether he actually resents is the trait roll below.
  (role ?bested [k human]
                (not (= ?bested @self))
                (select (score (co-present @self ?bested))
                        (policy roulette)))

  (when (believes {@self hold_meet_run}))

  (duration 60)

  (act-effects
    ; The club's articles (goal focus) -> its kind + employee_register; then the
    ; sport, an EXACT lookup on the club kind (a kindless club holds no contest).
    (bind (goal-focus hold_meet) ?art)
    (read-doc-record [k articles_of_incorporation] ?art (kind ?club_kind) (register ?reg))
    (bind (lookup club_sports org_kind ?club_kind sport) ?sport)
    (if ?sport
      (do
        ; PARTICIPATION: every co-present, living roster member keeps the memory
        ; of competing. co-present gates it so a member who did not attend gets
        ; nothing; (alive ?m) guards the cross-mind mint against a stale roster row.
        (for-each-doc-record [k employee_register] ?reg (worker ?m)
          (if (and (alive ?m) (co-present @self ?m))
              (begin-belief ?m {?m participated_in ?sport})))
        ; THE VICTOR takes the honours (skip the degenerate self-only draw).
        (if (not (= ?victor @self))
            (begin-belief ?victor {?victor won ?sport}))
        ; THE BESTED RIVAL resents the win with the narcissism x assertiveness
        ; roll (floor 0.15, trait scale 0.85 - the roll_outdo_resentment model),
        ; and records {victor outdo bested} in both principals' minds. Guarded to a
        ; distinct, non-self loser so a one-competitor meet mints no grudge.
        (if (and (not (= ?bested @self))
                 (not (= ?bested ?victor))
                 (chance (+ 0.15 (* 0.85 (attr ?bested narcissism)
                                        (attr ?bested assertiveness)))))
            (incident-anchor ?victor outdo ?bested))))
    (end-act {@self hold_meet_run})
    (end-goal {@self hold_meet})))
