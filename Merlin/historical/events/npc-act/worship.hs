; worship - the churchgoing lane in the B4 think -> act-goal -> act-behaviour model.
;
; ONE think, PRESSURE-driven (no separate desire event, no standing aim, no goal
; the act has to end):
;   feel_devout (npc-think): worship PRESSURE = days since the last service,
;     gated + scaled by politeness (respect for convention). It rises daily and
;     collapses the moment the NPC worships, so a devout man is drawn back ~weekly
;     while a secular one's utility never clears a routine act. Not at a church ->
;     a `go` sub-act-goal to one; at a church -> the `worship` act-goal there.
;   worship_act / go_act (npc-act): implement them. The {@self worship <church>}
;     act-belief - begun at commit, ended by (end-act) at completion - IS the
;     episodic service memory (interval = the service). days-since-last reads it
;     for the pressure; classify_piety reads it (any-tense) for the gist. So there
;     is no separate piety marker: the act IS the record.
;
; The act ends the belief and NOTHING ELSE about the think - an act-behaviour does
; its act with no knowledge of which think proposed it. The think ceases on its own
; because worshipping reset its pressure.

(include "../../definitions/roles.hs")

(npc-think feel_devout
  (short-term-think)
  (roles
    (role @self (template grown))
    ; The nearest church the NPC KNOWS (role-cast over its own church objects; the
    ; naked [k ..] is sugar for (believes {?this isa [k ..]})). No known church ->
    ; the role binds nothing and the think does not fire (find_building supplies the
    ; knowledge). Replaces the omniscient (venue ...) pick.
    (role ?venue [k building church] (prefer (near @self ?venue)) (policy weighted)))
  ; Only consider it once a service is ~due (perf: most passes skip). Utility ramps
  ; with the days since, x politeness, and is CAPPED as a LEISURE act (max ~40, well
  ; below work / meals / sleep) - worship fills free time, it never overrides a
  ; livelihood. A devout man reaches the cap ~monthly; a secular one's utility stays
  ; below every routine act, so he effectively never goes. The cap also bounds the
  ; never-worshipped case (days-since = sentinel) to the same leisure ceiling.
  (when (>= (days-since-last @self worship) 15))
  (utility (* (attr @self politeness) (min (* (days-since-last @self worship) 1.5) 40)))
  (effects (propose-venue-act ?venue worship)))

(npc-act worship_act
  (when (believes {@self worship ?church}))
  (duration 90)
  ; The act-belief {@self worship ?church} IS the service memory: ending it here
  ; closes its interval to [commit, now] (the ~90-min service). No marker, no aim.
  (effects (end-act {@self worship ?church})))
; go_act (the shared travel act) now lives in npc-act/go.hs.
