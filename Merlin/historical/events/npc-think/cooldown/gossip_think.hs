; ----------------------------------------------------------------------------
; gossip (npc-think). @self picks ONE co-present listener and the single most
; gossip-worthy thing @self knows about a THIRD PARTY - a witnessed scandal
; preferred over mere relationship news, and not already aired to that listener -
; and PROPOSES the telling. the shared say_to act says it aloud.
;
; ?x (gossiped ABOUT) is drawn by roulette from the people @self knows of; ?ear (the
; listener) from whoever shares @self's room (the location JOIN, cf. introduce.hs).
; for-each-present-tense-belief walks @self's OWN beliefs about ?x (the DEFAULT subject-anchored
; read - @self's own mind, never telepathy) in label-PRIORITY order (scandal labels
; first, so a scandal outranks relationship news), skips any already in a {@self SAY
; ... ?ear} memory (per-listener dedup), and applies the shame-seal - @self does not
; air a fact in which @self is the victim ((not (= ?tgt @self))). (break) stops at
; the first tellable fact and proposes it. A listener who hears it files ?x as an
; acquaintance - which is what lets a scandal cascade outward through ?x's network.
;
; Fired MONTHLY: the (chance) is extraversion + assertiveness weighted
; on top of the has-a-friend gate. Proposing nothing is a safe no-op.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think gossip
  (cooldown 1 m)
  (rng-stream behaviour)

  (role @self {@self friend ?})
  ; The person gossiped ABOUT: someone @self knows of, drawn by roulette.
  (role ?x (any_human ?x)
           (select (score 1) (policy roulette)))
  ; The LISTENER: a co-present person (objective room occupancy), drawn by roulette.
  (role ?ear (any_human ?ear)
             (spatial ?ear co-located @self)
             (select (score 1) (policy roulette)))

  ; Non-belief gates (out of the roles): don't gossip to ?x about themselves (a cross-
  ; role equality, so it lives in (when), not a cacheable role filter), extraversion +
  ; assertiveness weighted chance, and the minimum-age check.
  (when (and (!= ?ear ?x)
             (chance (* 0.3
                        (+ 0.5 (attr @self enthusiasm))
                        (+ 0.5 (attr @self assertiveness))))
             (>= (years-old @self) 12)))

  (utility want)

  (effects
    ; Label order IS priority: scandal acts, then the death-story, then relationship
    ; news. ?news is the matched fact; ?tgt its target (the shame-seal check).
    (for-each ?news-rel (every {? disinherit|insult|outdo|public_humiliation|seduce|expose|confront_publicly|divorce|prototype|condition|circumstance_of_death|spouse|fiancee|lover|child ?})
      (do
        ?news-rel.target: ?tgt
        (utterable-msg ?news-rel): ?msg
        (if (and (!= ?tgt @self)
                 (none {@self SAY ?msg ?ear}))
            (then (maintain-proposal {@self SAY ?msg ?ear}) (break)))))))
