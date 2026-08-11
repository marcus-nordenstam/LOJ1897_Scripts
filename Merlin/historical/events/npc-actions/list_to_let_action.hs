; ----------------------------------------------------------------------------
; list_to_let_action - the npc-ACT half of the letting supply (list_to_let.hs).
;
; Promoted at the house agent's office when {@self let ?prop} is the leaf. It
; files the dwelling on the agent's PUBLIC to-let register (a for_lease_listing
; document, [building] slot) and mints the owner-side {?prop availability
; for_rent} belief - the durable "advertised to let" signal the buyers' register
; read and landlord_estate.hs both consume. Reproduces hsim::list_for_lease in
; .hs: the abs-native listing document plus the owner's availability belief.
;
; The listing doc is placed in the office he is standing in (hsim never renders,
; so only the record content is load-bearing; the register read finds it by kind
; regardless of position). The act ends its own act-belief AND the standing let
; intent, so it lists each vacant dwelling exactly once.
; ----------------------------------------------------------------------------

(npc-action {@self let ?prop}
  (duration 60)
  (effects
    (create-entity [k for_lease_listing] (qual location (current-building @self))): ?listing
    (write-doc-record [k for_lease_listing] ?listing (building ?prop))
    (begin-belief {?prop availability [k for_rent]})
    (set-outcome {@self let ?prop} succ)))
