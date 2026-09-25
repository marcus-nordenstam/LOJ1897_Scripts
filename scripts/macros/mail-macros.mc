; ----------------------------------------------------------------------------
; mail_macros.mc - composing + POSTING outgoing mail, as define-macros.
;
; The mail model: a sender COMPOSES an addressed letter and hands it to the
; send-mail posting chain (send_mail_think.mc), which walks @self to a room
; holding an outgoing-mail-stack and deposits it. The magic mail service
; (deliver_posted_mail, engine) then drains every building's outgoing pile each
; morning and teleports each letter to the incoming mail-stack of the building at
; its WRITTEN address (address road + address-number). The addressee reads it at
; their next home round. No instant materialize-at-destination.
;
; The covert INTERCEPTION path (send-covert-letter / route_covert_letter) is a
; separate model (couriers, prying staff) and does NOT ride this service.
; ----------------------------------------------------------------------------

; (mail-space ?premises): the INCOMING mail room of ?premises - where the magic mail
; service lands delivered letters and where a resident/officer READS them. The first
; present of hallway / living-room / kitchen (else the premises' first room, else the
; premises itself) - the same resolution the engine's mail_space_of uses to deliver, so
; a reader querying (spatial (mail-space ?p) contents [k mail-stack] /env) finds exactly what the service dropped.
(define-macro mail-space (?premises)
  (first-present (spatial ?premises [k hallway])
                 (spatial ?premises [k living-room])
                 (spatial ?premises [k kitchen])
                 ?premises))


; (plant-letter [k <kind>] <msg> ?premises): leave an UNADDRESSED <kind> letter
; carrying <msg> at ?premises - a killer's kept forged draft as discoverable evidence
; in his own home, or an institutional filing (a crime report at a police station) no
; resident reads. NOT mailed: no address is written, so the magic service never routes
; it; it simply sits at ?premises for a later search / detective to find.
(define-macro plant-letter (?kind ?msg ?premises)
  (do
    (create-entity ?kind ?premises): ?ltr
    (set-writing ?ltr ?msg)))
