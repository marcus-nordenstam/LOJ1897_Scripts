; ----------------------------------------------------------------------------
; affair_consummate (hot npc-think) - (a) TAKING the opportunity to consummate an
; affair whenever the two lovers can be ALONE together, however they came to share a
; building: an engineered tryst (affair_rendezvous), co-attending an occasion, a
; shared workplace, or a live-in staff paramour under the same roof.
;
; Two rungs, the seek -> act shape of a fight:
;   tryst_slip     - a lover is in my BUILDING but we are not yet privately together
;                    (apart, or together with the spouse in the room). Slip off to a
;                    vacant room. Both lovers resolve the SAME (vacant-room ...) and
;                    converge there without signalling. This is the missing step: the
;                    household all clusters in the entrance room, so privacy must be
;                    SOUGHT.
;   affair_consummate - alone in a room with the lover (no spouse present) -> the
;                    durative HAVE_SEX_WITH act (consummate_action.hs, ~45 min), whose
;                    running holds them there long enough to land and to be caught.
;
; A per-day cooldown keeps one co-presence bout to a single tryst. Utility 95 clears
; the routine lanes (work 80, meals ~85) - lovers break away for it - but sits below
; the sleep-emergency / fight bands.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; SEEK: a lover shares my building but we are not yet alone together. Slip to a
; vacant room (the same one they resolve). Fire while apart, OR while together with
; the spouse in the room (the cue to peel away). Needs somewhere private to go.
(npc-think tryst_slip
  (cooldown 1 d)
  (role @self (adult @self)
              {@self lover ?})
  (role ?paramour (spatial ?paramour co-located @self /building)
                  (any_human ?paramour)
                  {@self lover ?paramour}
                  (not {@self spouse ?paramour}))
  ; A room in @self's building with no third party present - only @self and the paramour
  ; may be there. No private room -> no slip (the roomless-premises case is dropped).
  (role ?room (spatial (spatial @self building) parts [k interior_space room] /env)
              (not (spatial ?room contents [k human] /env @self ?paramour))
              (select (policy first-match)))
  (when (or (not (spatial ?paramour co-located @self))
            (spatial (spouse-of @self) co-located @self)))
  (utility want always-pick)
  (effects
    (debug-print "TRYST_SLIP @self para=?paramour")
    (maintain-proposal {@self WALK ?room})))

; ACT: alone in a room with the lover -> consummate. ?paramour is a live third-party
; lover @self BELIEVES shares his room (the location co-location role filter).
(npc-think affair_consummate
  (cooldown 1 d)
  (role @self (adult @self)
              {@self lover ?})
  (role ?paramour (spatial ?paramour co-located @self)
                  (any_human ?paramour)
                  {@self lover ?paramour}
                  (not {@self spouse ?paramour}))
  ; Discretion: not in the same ROOM as the wronged spouse. (spouse-of @self) is fail
  ; for an unmarried cheater, so the gate passes them through.
  (when (not (spatial (spouse-of @self) co-located @self)))
  (utility want always-pick)
  (effects
    (debug-print "CONSUMMATE_HOT @self para=?paramour")
    (maintain-proposal {@self HAVE_SEX_WITH ?paramour})))
