; ----------------------------------------------------------------------------
; theft_discovery - the wronged-party response to a missing possession.
;
; The engine's per-tick attention-whereabouts verify mints {@self found_missing
; ?prop} (a momentary perception fact) when an attended possession the NPC
; believed was HERE is physically gone. This rule construes that into a theft and
; seeds suspects - ENTIRELY from @self's own beliefs, fallibly (NO telepathy: the
; NPC cannot know where the thing actually went or who really took it).
;
;  - mine-check: the thing was in a building @self believes is their home.
;  - construe: {?prop stolen_from @self} (the suffer_loss anchor - focusless
;    anger/distress; the thief's identity stays unknown).
;  - suspicion-by-access: the first suspects are the people @self believes work
;    under their roof - cast from @self's OWN employment/coworker beliefs
;    ({?worker job ?j} + {?j org ?org}), fallible by construction (the servant is
;    suspected whether or not she took it). Seeds {@self suspect ?worker /aux
;    ?prop} for the report-letter accusation + interrogation lanes.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think theft_discovery
  (cooldown 0)
  (rng-stream behaviour)
  {@self found_missing ?prop}:?fm
  ; The attended thing vanished from @self's CURRENT room (the verify is bounded
  ; there), so @self's current building is where it was. Mine = that building is
  ; @self's home. NO read of the gone prop (it is gone - no telepathy).
  (role ?bldg (any_building ?bldg)
              (spatial @self building ?bldg)
              {@self home ?bldg})
  (when (none {?prop stolen_from @self}))
  (utility want)
  (effects
    (begin-belief {?prop stolen_from @self /momentary})
    ; Suspect up to 4 people I believe work under my roof (my org's workers).
    (for-each ?job-rel (every {@self employer ?org})
      ?job-rel.target: ?myorg
      (for-each ?worker-rel (every {? org ?myorg}) /limit 4
        ?worker-rel.subject: ?wjob
        (for-each ?holds-rel (every {? job ?wjob})
          ?holds-rel.subject: ?worker
          (if (and (!= ?worker @self)
                   (none {@self suspect ?worker}))
              (then (begin-belief {@self suspect ?worker /aux ?prop}))))))
    (end-belief ?fm)))
