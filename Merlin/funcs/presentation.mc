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
