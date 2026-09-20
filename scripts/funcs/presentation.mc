; ----------------------------------------------------------------------------
; presentation.mc - what a man LOOKS like, answered by the world rather than by
; the engine.
;
; GrymEngine owns the .spawn assets; which of them a given person wears is a fact
; about him - his sex and his standing - and so it is content. The host asks
; through mx_call and loads whatever comes back; it needs to know no label, no
; band and no table.
; ----------------------------------------------------------------------------

; (npc-spawn-file ?who) - the character .spawn ?who renders as, by gender and
; class-situation, off the npc_default_spawns table. The rows are tried specific
; first and then the per-gender `any` catch-all, which is what a man with no
; settled standing falls back to - a newborn, or one the classifiers have not
; reached yet.
;
; Gender is an ATTR (it is on the body, and anyone can see it). Class-situation is
; a SELF-BELIEF (it is what he takes himself to be), so it is read from inside his
; own mind - which is also why the attr read comes first, before the mind is
; entered.
(define-func npc-spawn-file (?who)
  (attr ?who gender): ?g
  (enter-mind ?who)
  (bind @nothing ?class)
  (if {@self class-situation ?band}
      (then (bind ?band ?class)))
  (if (table-match npc_default_spawns gender ?g class ?class file ?exact)
      (then ?exact)
      (else (if (table-match npc_default_spawns gender ?g class any file ?catch-all)
                (then ?catch-all)
                (else @nothing)))))

; ----------------------------------------------------------------------------
; THE PRESENTATION WALL - funcs only a presenting host implements.
;
; These four touch the GRYM SCENE: sockets, parenting, renderable flags and the
; TransformComponent. Nothing else in the corpus reaches that far, and no other
; process holds an implementation - hsim, mlint, Talkie and mxlog's ontology replay
; all resolve these names to a null eval, which is what forward-declared MEANS. A
; call reaching one of them there is a loud error naming the wall, so every call
; site sits inside an npc-action body under a (presented-lod) guard, which the
; wall-func-outside-action and wall-func-unguarded lint rules enforce.
;
; The Merlin HALF of each of these deeds is authored separately and runs at BOTH
; LODs: the grip edge is a spatial-write, the placement is a spatial-write, and the
; hidden flag is an attr. What crosses here is only the picture of it.
; ----------------------------------------------------------------------------

; (attach-to-socket ?thing ?holder ?socket) - hang ?thing on ?holder's socket and
; make it visible and non-colliding. ?socket is a side-bearing kind ([k left] /
; [k right]) or @nothing for a root attach, which is what stowing wants.
(declare-func attach-to-socket (args ?thing ?holder ?socket))

; (detach-entity ?thing) - take ?thing off whatever socket or parent holds it and
; make it a free, visible, ground-colliding root again. The socket scan is by
; ASSIGNMENT, not by side: a thing may have been stowed on the body or hung on
; either hand.
(declare-func detach-entity (args ?thing))

; (set-renderable ?thing ?on) - the ONE thing that distinguishes stowing (attach to
; the body and HIDE) from grasping (attach to a hand and SHOW). The scene twin of
; the Merlin-side hidden flag both LODs write for perception.
(declare-func set-renderable (args ?thing ?on))

; (place-entity ?thing ?point) - write the GRYM transform, the SECOND of the two
; writes a release needs. Merlin's bounds alone do not stick: the feedback pass
; reads the scene transform every frame for any ungripped prop and writes it back,
; and after a detach that transform still carries the hand-tip pose - so without
; this it would overwrite the point the rule reasoned about.
(declare-func place-entity (args ?thing ?point))

; (steer-facing ?who ?toward) - turn ?who toward ?toward SMOOTHLY, at the turn rate the
; act's (delib-turn-speed ..) put on it. The presented twin of (face-toward ..): the
; unpresented write snaps the box, a watched man swings round over several frames, and
; only the host owns the character controller that can do the second.
;
; ?toward is an ENTITY or a POINT. A target the actor himself controls - something in his
; own hand - is resolved through the pre-control snapshot rather than its live pose, or
; the mirror axis would chase the body that carries it.
(declare-func steer-facing (args ?who ?toward))

; (steer-to ?who ?point) - the PRESENTED movement write: turn ?who's character toward
; ?point at the act's (delib-turn-speed ..) and translate while it has ground or wall
; contact. The presented twin of (advance-toward ..), which moves the box directly. The
; speed is not an argument: the host blends it with the previous act's on the motor stack
; so a WALK into a RUN ramps with the visual blend. @true iff it translated.
(declare-func steer-to (args ?who ?point))

; (jump-impulse ?who) - launch ?who off the ground, once. The physics character controller
; owns it, and it only does anything while ?who is standing on something - a man already in
; the air cannot push off. An unpresented man has no ground to push off at all.
(declare-func jump-impulse (args ?who))

; (speak-aloud ?who ?msg) - render ?msg into words in ?who's own voice and SAY it: the
; natural-language pass, the visemes cut from the text, the jaw bone driven off them, the
; subtitle, and the speech-state slot that holds all of it for the utterance's life. A
; question keeps its '?' whatever the composer left off. None of it exists for an
; unpresented speaker - he is HEARD, through the sound entity the act mints at both LODs,
; and not watched.
(declare-func speak-aloud (args ?who ?msg))

; (speech-seconds ?who ?msg) - how long ?msg takes ?who to say, in seconds: the words
; rendered and the visemes cut, the same pass (speak-aloud ..) will run. A SAY's presented
; (duration ..) is this, so the act ends when the sound does. A message that renders to
; nothing answers one second, the flat utterance an unpresented say used to take.
(declare-func speech-seconds (args ?who ?msg))

; (end-speech ?who) - release the speech-state slot ?who claimed to speak. Must run on
; EVERY end of an utterance, conclusive or not: a slot leaked per interrupted sentence is a
; mouth that stops working after a few dozen conversations.
(declare-func end-speech (args ?who))
