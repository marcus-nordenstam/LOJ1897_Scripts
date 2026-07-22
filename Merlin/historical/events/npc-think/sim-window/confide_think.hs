; ----------------------------------------------------------------------------
; confide (npc-think). An NPC decides to share a private self-fact - their calling,
; the life passion they would not broadcast to strangers - with a trusted friend,
; and PROPOSES saying it aloud; the pure confide_act.hs emits the speech sound so
; perception delivers the fact to every co-present NPC and the friend hears it like
; anyone else in the room. Overhearing by another person present is the natural,
; emergent consequence of speaking aloud - the same model isim uses for the player
; and NPCs. The rarest of the conversation events - intimacy, not chatter - so the
; lowest chance.
;
; Fired by the per-NPC emergent pass, MONTHLY: the low extraversion-weighted chance
; gates the fire in (when) (a roll is a non-belief gate, never a role filter). The
; shared fact lands in each listener sourced to {@self SAY ...} (the tell-act + the
; pre-sim hear-tell adoption), so provenance is preserved: the listener knows @self
; TOLD them.
;
; `calling` is kind-valued ({@self calling [k medicine]}); the free ?domain in
; (believes {@self calling ?domain}) binds that kind, carried on the proposal so the
; confide_act can name it.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think confide
  (schedule cooldown 1 m)
  (rng-stream behaviour)

  ; @self the discloser: old enough to hold a calling (grown >= 16), actually
  ; has one (the filter fire-binds the calling KIND into ?domain for the tell),
  ; and has a friend to confide in.
  (role @self (grown @self)
              (believes {@self calling ?domain})
              (believes {@self friend ?}))

  ; Roll the disclosure - once per discloser per window, weighted by extraversion.
  (when (chance (* 0.08 (+ 0.5 (attr @self enthusiasm)))))

  (utility 15)

  (effects
    (maintain-proposal {@self confide ?domain})))
