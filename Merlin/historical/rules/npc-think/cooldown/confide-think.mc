; ----------------------------------------------------------------------------
; confide (npc-think). An NPC decides to share a private self-fact - their calling,
; the life passion they would not broadcast to strangers - with a trusted friend,
; and PROPOSES saying it aloud; the shared say_to act emits the speech sound so
; perception delivers the fact to every co-present NPC and the friend hears it like
; anyone else in the room. Overhearing by another person present is the natural,
; emergent consequence of speaking aloud - the same model isim uses for the player
; and NPCs. The rarest of the conversation rules - intimacy, not chatter - so the
; lowest chance.
;
; Fired by the per-NPC emergent pass, MONTHLY: the low extraversion-weighted chance
; gates the fire in (when) (a roll is a non-belief gate, never a role filter). The
; shared fact lands in each listener sourced to {@self SAY ...} (the tell-act + the
; pre-sim hear-tell adoption), so provenance is preserved: the listener knows @self
; TOLD them.
;
; `calling` is kind-valued ({@self calling [k medicine]}); the free ?domain in
; (any {@self calling ?domain}) binds that kind, carried on the proposal so the
; say_to msg can carry it.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think confide
  (cooldown 1 m)
  (rng-stream behaviour)

  ; @self the discloser: old enough to hold a calling (grown >= 16), actually
  ; has one (the filter fire-binds the calling KIND into ?domain for the tell),
  ; and has a friend to confide in.
  (role @self (grown @self)
              {@self calling ?domain}
              {@self friend ?})

  ; Roll the disclosure - once per discloser per month, weighted by extraversion.
  (when (chance (* 0.08 (+ 0.5 (attr @self enthusiasm)))))

  (utility want)

  (effects
    (nl-utterable-msg "I am called to ?domain"): ?msg
    (maintain-proposal {@self SAY ?msg _})))
