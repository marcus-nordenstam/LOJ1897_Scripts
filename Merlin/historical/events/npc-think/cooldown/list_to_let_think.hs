; ----------------------------------------------------------------------------
; list_to_let - the SUPPLY side of the property market (per-NPC replacement for
; the omniscient world-act/landlord_duties.hs). An owner advertises his OWN
; vacant residential building to let, from his OWN knowledge - no world scan.
;
; The annual disposition (a yearly timer) mints a standing intent {@self LET ?prop} for each vacant
; dwelling he owns. Vacancy is read entirely from his own beliefs (the
; knowledge-honest signal): a dwelling he owns, that is-a residential, that is
; NOT his home, that he holds no tenant belief for, and that he has not already
; listed. Inheritance deeds him the dwelling ({@self own}); a tenant's death /
; emigration ends his {?prop tenant}, so the vacancy surfaces without a scan.
;
; Routing then walks him to a house agency, where list_to_let_act (npc-action) files
; the for_lease_listing and mints {?prop availability for_rent} - the durable "to
; let" signal landlord_estate.hs already reads, AND the completion that retracts the
; intent: the same {?prop availability for_rent} drops the ?prop role, so the decision's
; cease-effects end {@self LET ?prop}. It mirrors the worship lane's routing so the
; supply never goes dormant merely because @self has not yet learned which orgs are
; house agencies:
;   KNOWS an agency, not there -> list_to_let_go   (travel to its office).
;   KNOWS no agency at all      -> list_to_let_find  (orient to learn one).
; AT a known agency the go sub-goal is spent, the let goal is the leaf and promotes to
; list_to_let_act - no dwell rung (list_to_let owns the goal's whole life).
;
;   list_to_let       : yearly timer - mint the standing {@self LET ?prop} intent;
;                       cease it when the dwelling's availability flips to for_rent.
;   list_to_let_go    : hold the intent, knows an agency, not there -> travel there.
;   list_to_let_find  : hold the intent, knows NO agency -> orient (learn one).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think list_to_let
  ; ANNUAL: a yearly timer mints the standing let intent once per year; (begin-goal) is
  ; idempotent.
  (cooldown 1 y)
  (role @self (adult @self))
  ; His OWN vacant residential holdings (object-cache role over his beliefs).
  (role ?prop {@self own ?prop}
              {?prop isa [k residential_building]}
              (not {@self home ?prop})            ; not where he lives
              (not {?prop tenant ?})              ; no sitting tenant
              (not {?prop availability [k for_rent]}))  ; not already listed
  (effects       (begin-goal {@self LET ?prop}))
  (cease-effects (end-goal   {@self LET ?prop})))
