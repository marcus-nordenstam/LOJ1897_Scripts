; ----------------------------------------------------------------------------
; stance-coupling (reflex, derive phase) - the durable relational residue of a feeling.
;
; A feeling toward a person, when it is NEW (a fresh emotion belief, or new information
; merged into one - a re-mint that brings a new cause), is felt on @self's stance toward
; that person. An edit that only re-stamps or decays the feeling is felt as nothing.
; A band it crosses into is caused by the feeling itself.
; ----------------------------------------------------------------------------

(reflex {@self emotion [k anger] ?focus}:?emotion
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (feel-stance ?focus warmth -0.4 ?emotion)
    (feel-stance ?focus esteem -0.1 ?emotion)
    (feel-stance ?focus trust -0.2 ?emotion)))

(reflex {@self emotion [k contempt] ?focus}:?emotion
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (feel-stance ?focus warmth -0.2 ?emotion)
    (feel-stance ?focus esteem -0.5 ?emotion)))

(reflex {@self emotion [k disgust] ?focus}:?emotion
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (feel-stance ?focus warmth -0.3 ?emotion)
    (feel-stance ?focus esteem -0.4 ?emotion)))

(reflex {@self emotion [k envy] ?focus}:?emotion
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (feel-stance ?focus esteem -0.3 ?emotion)))

(reflex {@self emotion [k jealousy] ?focus}:?emotion
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (feel-stance ?focus warmth -0.3 ?emotion)
    (feel-stance ?focus trust -0.2 ?emotion)))

(reflex {@self emotion [k fear] ?focus}:?emotion
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (feel-stance ?focus warmth -0.2 ?emotion)
    (feel-stance ?focus trust -0.3 ?emotion)
    (feel-stance ?focus dread 0.6 ?emotion)))

(reflex {@self emotion [k gratitude] ?focus}:?emotion
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (feel-stance ?focus warmth 0.4 ?emotion)
    (feel-stance ?focus trust 0.2 ?emotion)))

(reflex {@self emotion [k affection] ?focus}:?emotion
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (feel-stance ?focus warmth 0.5 ?emotion)))

(reflex {@self emotion [k admiration] ?focus}:?emotion
  (when (or (dirty-born) (dirty-cause)))
  (when (is-object ?focus))
  (when (not (eq ?focus @self)))
  (effects
    (feel-stance ?focus warmth 0.2 ?emotion)
    (feel-stance ?focus esteem 0.5 ?emotion)))
