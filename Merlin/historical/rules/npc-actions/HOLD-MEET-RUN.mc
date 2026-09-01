; ----------------------------------------------------------------------------
; hold_meet_run (npc-ACT) - the organiser's opening act of the club meet, decomposed
; into a TRUE npc-POV contest (act_body_purification + telepathy purge). The old
; single act picked the victor by (attr ?victor assertiveness) and the grudge by
; (attr ?bested narcissism) - reading OTHER people's hidden traits. Now nobody reads
; a trait off anyone else: each competitor SELF-simulates his run (RACE-RUN.hs) and
; the outcome is OBSERVABLE (a race-result belief minted into the co-present
; organiser), which the organiser reads from his OWN mind to declare the winner
; (JUDGE-DECLARE.hs).
;
; The act is the organiser PRESIDING - half an hour of officiating, and the ended
; {@self HOLD-MEET-RUN} act-belief that is his own record of the meet (the yearly
; hold-meet rung reads its days-since-last to retract the goal). It SUMMONS nobody:
; calling the field in is SPEAKING, and speaking is the SAY act's job - summon_field
; (sporting_event_think.hs) reads the roster and proposes one directed SAY per
; co-present member, ranked always-pick so the whole field is called before this
; fallback-ranked closing act can be selected.
; ----------------------------------------------------------------------------

(npc-action {@self HOLD-MEET-RUN ?art}
  (track-skill-level [k officiating])
  (duration 30)
  (effects
    (set-outcome {@self HOLD-MEET-RUN} /succ)))
