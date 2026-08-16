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
;     SUMMONS each co-present, living roster member - the organiser-subject told fact
;     ({@self summon <member> /aux <sport>}, held by both). The ended {@self HOLD_MEET_RUN} act-belief is the
;     organiser's own record of the meet (want_judge reads it, sporting_event_think.hs).
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
    (read-doc-record [k articles_of_incorporation] ?art (kind ?club_kind) (register ?reg))
    (if (is-kind (lookup club_sports org_kind ?club_kind sport))
      (then
        (lookup club_sports org_kind ?club_kind sport): ?sport
        ; Summon every co-present, living roster member: the organiser-subject
        ; summon act carries the sport in aux, told into the member (his
        ; standing ticket, naming whom to report to; race_act ends his copy)
        ; and recorded born-ended by the organiser (the call is an instant
        ; act - the ended belief is his own record of whom he called).
        (for-each-doc-record [k employee_register] ?reg (worker ?m)
          (if (and (alive ?m) (co-present ?m @self))
              (then (begin-belief ?m {@self summon ?m ?sport})
                    (begin-ended-belief {@self summon ?m ?sport}))))))
    (set-outcome {@self HOLD_MEET_RUN} succ)))
