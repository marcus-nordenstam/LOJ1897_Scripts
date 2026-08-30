; ----------------------------------------------------------------------------
; address ?doc ?recipient - the one dumb act of addressing a document to its
; recipient: stamp the envelope (addressee = the recipient's name, delivery
; address = where the recipient lives) so the mail lane can route + the recipient
; can claim it. Reading who / where is intrinsic to addressing a person; deciding
; WHOM to write to is the task's job.
; ----------------------------------------------------------------------------

(npc-action {@self ADDRESS ?doc ?recipient}
  (duration 2)
  (effects
    (set-attr ?doc addressee (attr ?recipient name))
    (if (any {?recipient home ?rhome})
        (then (set-attr ?doc address ?rhome)))
    (set-outcome {@self ADDRESS ?doc ?recipient} /succ)))
