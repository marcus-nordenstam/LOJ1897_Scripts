; ----------------------------------------------------------------------------
; UNPORTED (4.13 reference). The kill STRIKE terminal - extracted from
; means_cascade.hs when the place-lane crime passes were retired. Re-port as a
; (intra-day) terminal fired at co-presence (the killer and victim share a room),
; routing to the kill commit. NOT loaded (outside the events walk); kept here as
; the authoring reference for the kill-behaviour port.
;
; Original: fired by run_night_home_kill_strikes (preset ?actor + ?victim) with a
; (co-present ...) gate; the (strike ...) terminal routed to commit_kill_strike
; (dispatched on the committed occasion to the domestic / meal / street body).
; ----------------------------------------------------------------------------
(hsim-event means_strike
  (kind _means_strike)
  (roles (role ?actor  (template any_human))
         (role ?victim (template any_human)))
  (when (co-present ?actor ?victim))
  (effects
    (strike ?actor ?victim)))
