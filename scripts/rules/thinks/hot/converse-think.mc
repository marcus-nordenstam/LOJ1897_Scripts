; ----------------------------------------------------------------------------
; converse (thinks) - the life of a {@self converse ?partner} goal, begun by engage-hail
; (answer-hail-think.mc) at the utility of taking up the hail. The converse task pursues it
; until the task has concluded, and the goal ends with it.
; ----------------------------------------------------------------------------

(think converse-pursue
  (goal {@self converse ?partner})
  (when (not (converse-concluded ?partner)))
  (effects (maintain-proposal {@self converse ?partner})))

(think converse-done
  (goal {@self converse ?partner})
  (when (converse-concluded ?partner))
  (effects (set-outcome {@self goal {@self converse ?partner}} /succ)))
