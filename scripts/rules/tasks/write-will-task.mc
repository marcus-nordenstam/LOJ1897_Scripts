; ----------------------------------------------------------------------------
; write-will ?heir - pen a testament naming ?heir. deliberate-will (inheritance_think)
; decides the heir; this task performs the penning.
;
; The COMPOSING lives here, with the proposal, never in the WRITE action: an action
; may not compose a message, because the composed message is what the act carries and
; the task is what knows the sentence. A will is a WRITTEN MESSAGE, not a record - the
; bequest rides as (written-msg ..) and the named heir reads it back after the death.
;
; The bequest clause names the testator's coin pile. A pile is nameless and fungible,
; so it is described by WHERE it stands: the interior space of @self's home building.
; One sequence: destroy the old will if one stands, pen the blank, inscribe the bequest,
; own the signed paper. The paper it inscribes is the one it CREATED, kept under the
; running task's own key, so a restart re-reads that key instead of penning a second.
; ----------------------------------------------------------------------------

(task {@self write-will ?heir}:?write-will
  (tar @excl [k human] @object)
  (sequence
    (stage
      (effects
        (for-each ?own (every {@self own ?})
          (bind ?own.target ?owned)
          (if (and (is-a ?owned [k will]) (spatial ?owned co-located @self))
              (then (maintain-proposal {@self DESTROY-ENTITY ?owned}))))))

    (stage
      (effects
        (if (bb-any ?write-will will)
            (then (bind (bb-read ?write-will will) ?will))
            (else (maintain-proposal {@self CREATE-ENTITY [k will]}:?CREATE-ENTITY
                    [/postlude (bind (bb-read ?CREATE-ENTITY created) ?will)
                               (bb-write ?write-will will ?will)])))))

    (stage
      (when {@self name ?my-name})
      (effects
        (if (unsubstantial (attr ?will writing))
            (then (maintain-proposal {@self write-doc ?will
                    (written-msg [/author ?my-name]
                                 {?heir inherit
                                   (o [k pile] {@o space
                                     (o [k interior-space] {@o struct_parent
                                       (o [k building] {@self home @o})})})
                                   @self})})))))

    (stage
      (effects
        (if -{@self own ?will}
            (then (begin-belief {@self own ?will})))
        (bb-clear ?write-will will)
        (set-outcome ?write-will /succ)))))
