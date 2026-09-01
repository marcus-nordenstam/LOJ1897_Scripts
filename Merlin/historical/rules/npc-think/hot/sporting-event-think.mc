; ----------------------------------------------------------------------------
; sporting_event - the club ORGANISER's annual meet, the think + routing half.
; (The act half - the contest itself - lives in rules/npc-act/hold-meet.hs.)
;
; Replaces the old zero-role world sweep (world-act/sports.hs + the C++
; run_effect_hold_sporting_events). No omniscient club/roster/jockey scan: the
; organiser is a real deliberating NPC who reasons from HIS OWN club beliefs and
; acts at HIS OWN clubhouse.
;
;   hold-meet (yearly timer): the club's founder/head resolves ONCE a year to
;     hold his club's meet. He role-casts his OWN club from the founder / record
;     beliefs he minted at found-club-seq (no scan) and latches a standing
;     {@self hold-meet <club-articles>} goal.
;   hold_meet_go / summon_field / hold_meet_dwell: while the goal stands, hold_meet_go
;     walks him to his clubhouse (articles-building; the generic enter chain does the
;     travel) and cedes on arrival; once he is inside summon_field proposes a directed
;     SAY per co-present roster member (always-pick, so the field is called first) and
;     hold_meet_dwell proposes the closing {@self HOLD-MEET-RUN} act (fallback).
;   compete: the COMPETITOR's half - a member the organiser summoned proposes his own
;     {@self RACE-RUN} act (race_act runs his leg from his own attributes).
;
; The SPORT is authored content read per club kind from tables/club_sports.hs; the
; roster is the employee-register the organiser legitimately holds - both read in
; summon_field below, never in an act body (an act reasons about nothing).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

; --- routing: get the organiser to his clubhouse, then propose the on-site act ---
; The clubhouse is the goal focus's premises (articles-building), role-free (recovered from
; the standing goal, never a scan). Three rungs, all gated on the standing {@self hold-meet}:
; hold_meet_go (maintenance) holds {@self enter ?clubhouse} while he is not yet inside (the
; generic enter chain does the travel) and ceases it on arrival; summon_field and
; hold_meet_dwell, once he is inside, propose the summonses and then the closing act, ordered
; by always-pick / fallback. When hold-meet ceases the standing goal, hold_meet_go loses its
; parent and retracts, and both inside rungs stop proposing.
(npc-think hold_meet_go
  (goal {@self hold-meet ?art})
  (when (and (articles-building ?art ?clubhouse)
             (not (spatial @self building ?clubhouse))))
  (effects (maintain-proposal {@self enter ?clubhouse})))

; The organiser SUMMONS the field by SPEAKING: one directed SAY per co-present, living
; roster member ({@self summon <him> /aux <sport>}, his ticket to report - race_act ends
; his copy). The club's articles give the org, its kind gives the sport (an exact
; club_sports lookup; a kindless club holds no contest) and the employee-register gives
; the roster - all documents the organiser legitimately holds, read HERE because reading
; is deliberation and an act reasons about nothing. Nothing is written into a member's
; mind; awareness is by earshot. The per-listener SAY dedup retires each summons once
; said, so the rung empties itself when the field is called.
(npc-think summon_field
  (goal {@self hold-meet ?art})
  (when (and (articles-building ?art ?clubhouse)
             (spatial @self building ?clubhouse)))
  (utility always-pick)
  (effects
    (o {?art declares-org @o}): ?org
    (any {?org isa ?club_kind})
    (any {?org employee-register ?reg})
    (if (table-match club_sports org-kind ?club_kind sport ?sport)
      (then
        (for-each-row (attr ?reg writing) (worker ?m)
          (do
            (utterable-msg {@self summon ?m ?sport}): ?msg
            (if (and (alive ?m)
                     (spatial ?m co-located @self)
                     -{@self SAY ?msg ?m})
                (then (maintain-proposal {@self SAY ?msg ?m})))))))))

; The CLOSING act: half an hour presiding, and the {@self HOLD-MEET-RUN} record the yearly
; rung reads to retract the goal. fallback-ranked, so it is only selected once summon_field
; has nothing left to say - the field is called in BEFORE the meet is declared open.
(npc-think hold_meet_dwell
  (goal {@self hold-meet ?art})
  (when (and (articles-building ?art ?clubhouse)
             (spatial @self building ?clubhouse)))
  (utility fallback)
  (effects (maintain-proposal {@self HOLD-MEET-RUN ?art})))

; --- the organiser OWNS the judge goal off the scoreboard he holds ----------------
; Each racer's race_act mints {?racer race-result <score> <sport>} into the
; co-present organiser. While any such score stands unjudged this MAINTENANCE
; think holds the standing {@self judge-meet} goal that sporting_judge reads
; (sporting_judge_think.hs) to pick + propose the winner; meet_judged clearing
; the scoreboard then retracts the goal. The days-since guard bars a straggler
; score (a racer still running when the winner was declared) from re-opening
; the judging the same day.
(npc-think want_judge
  (role ?racer {?racer race-result ?})
  (when (>= (days-since-last {@self JUDGE-DECLARE /ever}) 1))
  (utility want)
  (effects       (begin-goal {@self judge-meet}))
  (cease-effects (end-goal   {@self judge-meet})))

; --- the COMPETITOR's terminal: a summoned member proposes his own race act --------
; open_meet_act told this member {?judge summon @self /aux ?sport}; while that
; ticket stands he PROPOSES the {@self RACE-RUN} act each env-cycle (race_act
; drains it and ends his copy of the summons, so the propose stops once his leg
; is run). Utility above routine so the obligation to compete pulls him off
; idler errands for the one run.
(npc-think compete
  (role ?judge {?judge summon @self ?sport})
  (utility want)
  (effects (maintain-proposal {@self RACE-RUN ?sport ?judge})))
