; ----------------------------------------------------------------------------
; write_will - the clerical WRITE act of the inheritance lane (deliberate_will
; decides; this pens the paper). @self records the chosen ?heir in their OWN
; will: update the existing testament in place if one is already filed, else
; create a fresh will document at @self's current building. Idempotent - one
; will per testator, re-pointed as the choice changes over a lifetime.
; ----------------------------------------------------------------------------

(npc-action {@self WRITE_WILL ?heir}
  (duration 30)
  (effects
    (bind 0 ?found)
    (for-each ?w (documents [k will])
      (do
        (read-doc-record [k will] ?w (testator ?t))
        (if (= ?t @self)
            (then
              (update-doc-record [k will] ?w (heir ?heir))
              (bind 1 ?found)
              (break)))))
    (if (= ?found 0)
        (then
          (create-entity [k will] (qual location (spatial @self building))): ?nw
          (write-doc-record [k will] ?nw (testator @self) (heir ?heir))))
    (set-outcome {@self WRITE_WILL ?heir} succ)))
