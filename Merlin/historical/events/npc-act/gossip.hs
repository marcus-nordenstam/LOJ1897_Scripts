; ----------------------------------------------------------------------------
; gossip (npc-act). An NPC SAYS ALOUD the single most gossip-worthy thing they
; know about a third party (a witnessed scandal preferred over mere relationship
; news) - and have not already aired. (top-untold-belief @self _ _ <labels>) ranks
; the actor's about-others beliefs by the label list (scandal first), skips any
; they already hold a {@self SAY ...} memory of (so they never repeat the same
; gossip), and applies the leaky-silence shame-seal (a victim does not broadcast
; their own disgrace). (tell ...) emits a real speech sound, so perception delivers
; the fact to whoever is co-present and the adoption pass files the gossiped-about
; party as an acquaintance in each listener - which is what lets a scandal cascade
; outward through the subject's widening acquaintance network. Telling nothing (the
; selector found nothing fresh) is a safe no-op.
;
; An ACT (tell) carried by perception, so npc-act. Fired by the per-NPC emergent
; pass MONTHLY: the (chance) is extraversion-weighted (enthusiasm + assertiveness)
; on top of the structural has-a-friend gate. Overhearing by anyone present is
; emergent - the same model isim uses for spoken messages.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour gossip
  (long-term-think)
  (rng-stream behaviour)

  (roles
    (role @self (any_human @self)
                (believes {@self friend ?})))

  ; Non-belief gates (out of the role): extraversion-weighted (chance, first so it
  ; short-circuits) and the minimum-age check.
  (when (and (chance (* 0.3
                        (+ 0.5 (attr @self enthusiasm))
                        (+ 0.5 (attr @self assertiveness))))
             (>= (years-old @self) 12)))

  (effects
    ; Say the freshest untold scandal / news the actor holds about ANYONE in their
    ; circle (about = _), to whoever is co-present (audience = _, broadcast -> the
    ; "told" exclusion is global). Label order IS priority: scandal acts, then the
    ; death-story, then relationship news.
    (tell (top-untold-belief @self _ _
            assault disinherit insult outdo discredit public_humiliation
            seduce expose spread_rumour confront_publicly divorce prototype
            circumstances_of_death
            spouse fiancee lover child))
    ))
