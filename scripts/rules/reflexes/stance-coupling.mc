; ----------------------------------------------------------------------------
; stance-coupling (npc-reflex, derive phase) - the durable relational residue of a feeling.
;
; A feeling toward a person, when it is NEW (a fresh emotion belief, or new information
; merged into one - a re-mint that brings a new cause), nudges @self's standing stance
; toward that person. An edit that only re-stamps or decays the feeling nudges nothing.
; A band the nudge crosses into is caused by the feeling itself.
; ----------------------------------------------------------------------------

(define-macro stance-lr () 0.2)

(npc-reflex {@self emotion [k anger] ?focus}:?e
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (nudge-stance ?focus warmth (* -0.4 (stance-lr)) ?e)
    (nudge-stance ?focus esteem (* -0.1 (stance-lr)) ?e)
    (nudge-stance ?focus trust (* -0.2 (stance-lr)) ?e)))

(npc-reflex {@self emotion [k contempt] ?focus}:?e
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (nudge-stance ?focus warmth (* -0.2 (stance-lr)) ?e)
    (nudge-stance ?focus esteem (* -0.5 (stance-lr)) ?e)))

(npc-reflex {@self emotion [k disgust] ?focus}:?e
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (nudge-stance ?focus warmth (* -0.3 (stance-lr)) ?e)
    (nudge-stance ?focus esteem (* -0.4 (stance-lr)) ?e)))

(npc-reflex {@self emotion [k envy] ?focus}:?e
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (nudge-stance ?focus esteem (* -0.3 (stance-lr)) ?e)))

(npc-reflex {@self emotion [k jealousy] ?focus}:?e
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (nudge-stance ?focus warmth (* -0.3 (stance-lr)) ?e)
    (nudge-stance ?focus trust (* -0.2 (stance-lr)) ?e)))

(npc-reflex {@self emotion [k fear] ?focus}:?e
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (nudge-stance ?focus warmth (* -0.2 (stance-lr)) ?e)
    (nudge-stance ?focus trust (* -0.3 (stance-lr)) ?e)
    (nudge-stance ?focus dread (* 0.6 (stance-lr)) ?e)))

(npc-reflex {@self emotion [k gratitude] ?focus}:?e
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (nudge-stance ?focus warmth (* 0.4 (stance-lr)) ?e)
    (nudge-stance ?focus trust (* 0.2 (stance-lr)) ?e)))

(npc-reflex {@self emotion [k affection] ?focus}:?e
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (nudge-stance ?focus warmth (* 0.5 (stance-lr)) ?e)))

(npc-reflex {@self emotion [k admiration] ?focus}:?e
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (nudge-stance ?focus warmth (* 0.2 (stance-lr)) ?e)
    (nudge-stance ?focus esteem (* 0.5 (stance-lr)) ?e)))
