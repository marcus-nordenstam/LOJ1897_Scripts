; ----------------------------------------------------------------------------
; write-will ?heir - pen a testament naming ?heir. deliberate_will (inheritance_think)
; decides the heir; this task performs the penning.
;
; The COMPOSING lives here, with the proposal, never in the WRITE action: an action
; may not compose a message, because the composed message is what the act carries and
; the task is what knows the sentence. A will is a WRITTEN MESSAGE, not a record - the
; bequest rides as (written-msg ..) and the named heir reads it back after the death.
;
; The bequest clause names the testator's coin pile. A pile is nameless and fungible,
; so it cannot ride by name: it is DESCRIBED by its place - "the pile in a room of my
; home" - and the nested (o ..) descriptors resolve in the READER, inside-out, bottoming
; out at the SIGNED author via the acquaintance-disclosed `home`. Because written-msg
; QUOTES its content, those (o ..) forms are never evaluated here; they travel as the
; descriptors they are.
;
; One will per testator ({@self own ?will}); a re-deliberation supersedes the prior
; testament in place - destroy, then re-pen.
; ----------------------------------------------------------------------------

(npc-task {@self write-will ?heir}:?ww-rel
  (tar @excl human)
  (and
    ; Supersede: a will @self already owns goes before the new one is penned.
    (try
      (role ?old [k will] {@self own ?old}
                          (spatial ?old co-located @self))
      (when -{@self CREATE-ENTITY [k will] /succ /caused_by ?ww-rel})
      (effects (maintain-proposal {@self DESTROY-ENTITY ?old})))
    ; Pen the paper.
    (try
      (when -{@self CREATE-ENTITY [k will] /succ /caused_by ?ww-rel})
      (effects (maintain-proposal {@self CREATE-ENTITY [k will]})))
    ; Inscribe the bequest.
    (try
      (role ?will [k will] (spatial ?will co-located @self)
                           (not (substantial (attr ?will writing))))
      (effects
        (maintain-proposal {@self WRITE ?will
          (written-msg {?heir inherit
                         (o [k pile] {@o space
                           (o [k interior-space] {@o struct_parent
                             (o [k building] {@self home @o})})})}
                       signed)})))
    ; Owned and witnessed by its writing - the testament stands.
    (try
      (role ?will [k will] (spatial ?will co-located @self)
                           (substantial (attr ?will writing)))
      (when -{@self own ?will})
      (effects
        (begin-belief {@self own ?will})
        (set-outcome ?ww-rel /succ)))))
