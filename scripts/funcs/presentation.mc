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
