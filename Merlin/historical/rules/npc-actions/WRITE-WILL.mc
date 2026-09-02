; ----------------------------------------------------------------------------
; write_will - the testator pens their will (deliberate_will decides the heir).
;
; A will is a WRITTEN MESSAGE, not a record: its bequest clause is composed with
; (written-msg ...) and attached with (set-writing), and the named heir reads it
; back with (adopt-msg ...) after the death. The clause bequeaths the testator's
; coin pile to ?heir - and because a coin pile is a nameless, fungible object it
; cannot ride the wire by name, so it is DESCRIBED by its place: "the pile in a
; room of my home". The nested (o ...) descriptor resolves in the reader inside-
; out, bottoming out at the SIGNED author (@self -> @i, the named testator) via
; the acquaintance-disclosed `home`.
;   (NB: this leans on the v2 relational-descriptor resolver in the message codec
;    - a nameless object described by a spatial constitutive clause. That resolver
;    is not wired yet; the .hs is authored ahead of it.)
;
; One will per testator, tracked by {@self own ?will}; a re-deliberation supersedes
; the prior testament in place (destroy + re-pen).
; ----------------------------------------------------------------------------

(npc-action {@self WRITE-WILL ?heir}
  (track-skill-level [k law])
  (duration 30)
  (effects
    ; Supersede a prior will.
    (for-each ?old (env-entities [k will])
      (do (if {@self own ?old}
              (then (destroy-entity ?old) (break)))))
    ; Pen the testament at @self's current building, bequeathing the coin pile
    ; (described by location) to ?heir, and record ownership of the document.
    (create-entity [k will] (spatial @self space)): ?will
    (set-writing ?will
      (written-msg {?heir inherit
                     (o [k pile] {@o space
                       (o [k interior-space] {@o struct_parent
                         (o [k building] {@self home @o})})})}
                   signed))
    (begin-belief {@self own ?will})
    (set-outcome {@self WRITE-WILL ?heir} /succ)))
