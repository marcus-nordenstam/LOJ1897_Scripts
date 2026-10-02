; ----------------------------------------------------------------------------
; grievance-macros - the shared scoring vocabulary the pressure-response rules
; (rules/thinks/cooldown/grievance-*.mc) compose their drive from.
;
; A standing {@self pressure <kind> /aux <focus>} belief is a grievance: something
; happened, it is directed at someone, and it has not been spent. Each response rule
; owns ONE outlet for it and reads its drive from here: how hot the grievance is
; (pressure-intensity), how far the actor's disposition tilts toward that CLASS of
; outlet (agg-tilt / pro-tilt), and whether a held rationalisation compounds it.
;
; The tilts are per-CLASS, not per-action: which class an outlet belongs to is
; settled by which macro its rule calls, so there is no action dispatch here.
; ----------------------------------------------------------------------------





; ----------------------------------------------------------------------------
; Routine-drive personality tilts (NOT grievance) - the disposition scaling the
; WORSHIP / work drive utilities carry, reusing the centered-swing helpers above.
; Worship rises with politeness (respect for convention), work with industriousness
; and falls with stress (the stressed shirk). Applied in-band in each drive rule's
; (declare-utility), so a diligent / devout NPC out-ranks a shirker / lapsed one.
; ----------------------------------------------------------------------------
