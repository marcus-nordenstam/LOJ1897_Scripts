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



