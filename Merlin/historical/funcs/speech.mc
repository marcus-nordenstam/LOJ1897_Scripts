; ----------------------------------------------------------------------------
; speech.mc - the PHYSICAL half of a speech act, as content.
;
; This was C++ (env/functions/comms_functions.h emit_tell) and had no business
; being there: it hardcoded the SAY label, the [k speech] sound kind and the
; earshot radius. All three are world knowledge, so they live here.
;
; No act-belief is made here. {@self SAY <msg> <audience>} is minted by the action
; pipeline when a SAY proposal wins selection and externalized to the abs mind at
; promotion; SAY.mc's (xaction ?xsay) hands this func that ABS twin. All that is
; left is making it audible: a [k speech] sound entity at the speaker's own bounds
; carrying the twin, so the objective record the world hears can never drift from
; the speaker's own. Co-present NPCs overhear it on the next perception pass; a
; preroll of 0 makes it audible this instant.
;
; A DIRECTED say stamps the addressee in the act's /aux (the per-listener "told"
; dedup); a BROADCAST leaves it absent. Delivery is by co-presence either way -
; the addressee is who it is ADDRESSED to, never who receives it.
; ----------------------------------------------------------------------------

(define-func deliver-speech (?xsay)
  (do
    (create-entity [k speech] (spatial @self bounds)): ?sound
    (set-attr ?sound create-action ?xsay)
    (set-attr ?sound speaker @self)
    (set-attr ?sound preroll 0)))
