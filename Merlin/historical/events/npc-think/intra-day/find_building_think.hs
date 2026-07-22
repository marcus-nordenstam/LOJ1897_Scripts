; ----------------------------------------------------------------------------
; find_building (npc-think lane) - the deliberation half of the venue-discovery
; search (act_body_purification). The seek rules maintain the standing
; {@self find_building [k building <kind>]} goal; these two generic thinks turn a
; won slot into a survey hop or an idle.
;
; UTILITY-NEUTRAL: find_survey proposes at (utility 0), so - /causing the find goal -
; it competes at EXACTLY the goal's inherited drive, the same weight the old
; auto-proposed find goal carried. find_stall carries (utility -1) so it strictly
; LOSES to find_survey whenever a vantage remains, yet stands in for the find lane's
; idle when the frontier is exhausted (find_survey casts no ?next). Both /cause the
; standing find goal.
; ----------------------------------------------------------------------------

(npc-think find_survey
  (schedule always)
  (goal {@self find_building ?sought})
  (role ?next [k building]
        (bb-none ?next surveyed)
        (select (score (distance @self ?next)) (policy argmin)))
  (utility 0)
  (effects (propose {@self find_building ?sought ?next})))

(npc-think find_stall
  (schedule always)
  (goal {@self find_building ?sought})
  (utility -1)
  (effects (propose {@self find_stall ?sought})))
