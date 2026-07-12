; ----------------------------------------------------------------------------
; confide (npc-act). An NPC shares a private self-fact - their calling, the life
; passion they would not broadcast to strangers - with a trusted friend, by
; SAYING it aloud (the tell-act). The friend cast into ?confidant is the reason
; the NPC speaks at all; the tell-act emits a real speech sound, so perception
; delivers the fact to every co-present NPC and the friend (the intended ear)
; hears it like anyone else in the room. Overhearing by another person present is
; the natural, emergent consequence of speaking aloud - the same model isim uses
; for the player and NPCs. The rarest of the conversation events - intimacy, not
; chatter - so the lowest chance.
;
; An ACT (tell) carried by perception, so npc-act (an event whose effects perform
; an action, not just mint a belief in @self's own mind). Fired by the per-NPC
; emergent pass, MONTHLY: the low extraversion-weighted chance gates the fire in
; (when) (a roll is a non-belief gate, never a role filter). The shared fact lands
; in each listener sourced to {@self SAY ...} (the tell-act + the pre-sim
; hear-tell adoption), so provenance is preserved: the listener knows @self TOLD
; them.
;
; `calling` is kind-valued ({@self calling [k medicine]}); the free ?domain in
; (believes {@self calling ?domain}) binds that kind so the tell-act can name it.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-think confide
  (sim-window-think)
  (rng-stream behaviour)

  ;; @self the discloser: old enough to hold a calling (grown >= 16), actually
  ;; has one (binds ?domain - the kind they will name aloud), and has a friend
  ;; to confide in (?confidant). Belief queries only - no chance/attr in a role.
  (role @self (grown @self)
              (believes {@self calling ?domain})
              (believes {@self friend ?confidant}))

  ;; The disclosure roll - once per discloser per window, weighted by extraversion.
  ;; A (chance)/(attr) gate is non-belief, so it lives in (when), not the role.
  (when (chance (* 0.08 (+ 0.5 (attr @self enthusiasm)))))

  (act-effects
    ;; Say the calling ALOUD. The tell-act makes a speech sound at @self's
    ;; location; the post-effects auditory pass delivers + adopts {@self calling
    ;; ?domain} into ?confidant (and anyone else co-present), sourced to the
    ;; spoken {@self SAY ...} record.
    (tell {@self calling ?domain})
    ))
