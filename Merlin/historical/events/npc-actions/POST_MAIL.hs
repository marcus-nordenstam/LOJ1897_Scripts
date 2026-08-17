; ----------------------------------------------------------------------------
; post_mail (npc-action) - the dumb hands act the send_mail task proposes: file the
; outgoing document ?doc into ?out, the outgoing_mail_stack @self is standing at (the
; post_mail_put think bound it by location and walked @self there). The magic mail
; service then teleports ?doc to the addressee building. Filing a doc INTO a pile is
; env mutation, so only an ACTION may do it - the inverse of scan_mail.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self POST_MAIL ?doc ?out}
  (duration 5)
  (effects
    (push ?doc ?out)
    (set-outcome {@self POST_MAIL ?doc ?out} succ)))
