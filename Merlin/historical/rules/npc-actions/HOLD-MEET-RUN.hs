; ----------------------------------------------------------------------------
; hold_meet_run (npc-ACT) - the organiser's opening act of the club meet, decomposed
; into a TRUE npc-POV contest (act_body_purification + telepathy purge). The old
; single act picked the victor by (attr ?victor assertiveness) and the grudge by
; (attr ?bested narcissism) - reading OTHER people's hidden traits. Now nobody reads
; a trait off anyone else: each competitor SELF-simulates his run (RACE_RUN.hs) and
; the outcome is OBSERVABLE (a race_result belief minted into the co-present
; organiser), which the organiser reads from his OWN mind to declare the winner
; (JUDGE_DECLARE.hs).
;
;   HOLD_MEET_RUN (organiser): reads his club's SPORT + ROSTER (own documents) and
;     SUMMONS each co-present, living roster member by SPEAKING the call - a directed
;     utterance each member hears and adopts as his own standing summons
;     ({<organiser> summon <him> /aux <sport>}, his ticket to report). The ended
;     {@self HOLD_MEET_RUN} act-belief is the organiser's own record of the meet.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; The organiser opens the meet: summon the co-present field and record the sport (the
; want_judge think holds the judge goal off it). The victor/grudge deliberation is GONE -
; this act reads no trait.
(npc-action {@self HOLD_MEET_RUN ?art}
  (duration 30)
  (effects
    ; The club's articles (carried on the act-belief) -> its kind + roster; then the
    ; sport, an EXACT lookup on the club kind (a kindless club holds no contest).
    (o {?art declares_org @o}): ?org
    (any {?org isa ?}).target: ?club_kind
    (any {?org employee_register ?}).target: ?reg
    (if (table-match club_sports org_kind ?club_kind sport ?sport)
      (then
        ; Summon every co-present, living roster member by SPEAKING the call: a
        ; directed utterance the member hears and adopts as his own standing summons
        ; ({<organiser> summon <him> /aux <sport>}, his ticket to report; race_act ends
        ; his copy). Nothing is written into his mind - awareness is by earshot.
        (for-each-row (attr ?reg writing) (worker ?m)
          (if (and (alive ?m) (spatial ?m co-located @self))
              (then (tell-to ?m (utterable-msg (to ?m) {@self summon ?m ?sport})))))))
    (set-outcome {@self HOLD_MEET_RUN} /succ)))
