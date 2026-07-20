; ----------------------------------------------------------------------------
; gossip (npc-think). @self tells ONE co-present listener the single most gossip-
; worthy thing @self knows about a THIRD PARTY - a witnessed scandal preferred over
; mere relationship news, and not already aired to that listener.
;
; ?x (gossiped ABOUT) is drawn by roulette from the people @self knows of; ?ear (the
; listener) from whoever shares @self's room (the location JOIN, cf. introduce.hs).
; for-each-belief walks @self's OWN beliefs about ?x (the DEFAULT subject-anchored
; read - @self's own mind, never telepathy) in label-PRIORITY order (scandal labels
; first, so a scandal outranks relationship news), skips any already in a {@self SAY
; ... ?ear} memory (per-listener dedup), and applies the shame-seal - @self does not
; air a fact in which @self is the victim ((not (= ?tgt @self))). (break) stops at
; the first tellable fact. A listener who hears it files ?x as an acquaintance -
; which is what lets a scandal cascade outward through ?x's widening network.
;
; Fired MONTHLY (sim-window): the (chance) is extraversion + assertiveness weighted
; on top of the has-a-friend gate. Telling nothing is a safe no-op.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-think gossip
  (schedule cooldown 1 m)
  (rng-stream behaviour)

  (role @self (believes {@self friend ?}))
  ; The person gossiped ABOUT: someone @self knows of, drawn by roulette.
  (role ?x (any_human ?x)
           (select (score 1) (policy roulette)))
  ; The LISTENER: a co-present person (objective room occupancy), drawn by roulette.
  (role ?ear (any_human ?ear)
             (co-present @self)
             (select (score 1) (policy roulette)))

  ; Non-belief gates (out of the roles): don't gossip to ?x about themselves (a cross-
  ; role equality, so it lives in (when), not a cacheable role filter), extraversion +
  ; assertiveness weighted chance, and the minimum-age check.
  (when (and (not (= ?ear ?x))
             (chance (* 0.3
                        (+ 0.5 (attr @self enthusiasm))
                        (+ 0.5 (attr @self assertiveness))))
             (>= (years-old @self) 12)))

  (effects
    ; Label order IS priority: scandal acts, then the death-story, then relationship
    ; news. ?news is the matched fact; ?tgt its target (the shame-seal check).
    (for-each-belief ?news {?x assault|disinherit|insult|outdo|discredit|public_humiliation|seduce|expose|spread_rumour|confront_publicly|divorce|prototype|condition|circumstances_of_death|spouse|fiancee|lover|child ?tgt}
      (do
        (if (and (not (= ?tgt @self))
                 (not (believes {@self SAY (utterable-msg ?news) ?ear})))
            (do (tell-to ?ear ?news) (break)))))))
