; ----------------------------------------------------------------------------
; list_to_let - the SUPPLY side of the property market (per-NPC replacement for
; the omniscient world-act/landlord_duties.hs). An owner advertises his OWN
; vacant residential building to let, from his OWN knowledge - no world scan.
;
; The annual disposition (a yearly timer) mints a standing intent {@self let ?prop} for each vacant
; dwelling he owns. Vacancy is read entirely from his own beliefs (the
; knowledge-honest signal): a dwelling he owns, that is-a residential, that is
; NOT his home, that he holds no tenant belief for, and that he has not already
; listed. Inheritance deeds him the dwelling ({@self own}); a tenant's death /
; emigration ends his {?prop tenant}, so the vacancy surfaces without a scan.
;
; Routing then walks him to a house agency, where list_to_let_act (npc-act) files
; the for_lease_listing and mints {?prop availability for_rent} - the durable "to
; let" signal landlord_estate.hs already reads, AND the completion that retracts the
; intent: the same {?prop availability for_rent} drops the ?prop role, so the decision's
; cease-effects end {@self let ?prop}. It mirrors the worship lane's routing so the
; supply never goes dormant merely because @self has not yet learned which orgs are
; house agencies:
;   KNOWS an agency, not there -> list_to_let_go   (travel to its office).
;   KNOWS no agency at all      -> list_to_let_find  (orient to learn one).
; AT a known agency the go sub-goal is spent, the let goal is the leaf and promotes to
; list_to_let_act - no dwell rung (list_to_let owns the goal's whole life).
;
;   list_to_let       : yearly timer - mint the standing {@self let ?prop} intent;
;                       cease it when the dwelling's availability flips to for_rent.
;   list_to_let_go    : hold the intent, knows an agency, not there -> travel there.
;   list_to_let_find  : hold the intent, knows NO agency -> orient (learn one).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think list_to_let
  ; ANNUAL: a yearly timer mints the standing let intent once per year. No cadence marker -
  ; the (schedule ...) is the cadence; (begin-goal) is idempotent.
  (schedule cooldown 1 y)
  (if-blocked hold)
  (role @self (adult @self))
  ; His OWN vacant residential holdings (object-cache role over his beliefs).
  (role ?prop (believes {@self own ?prop})
              (believes {?prop isa [k residential_building]})
              (not (believes {@self home ?prop}))            ; not where he lives
              (not (believes {?prop tenant ?}))              ; no sitting tenant
              (not (believes {?prop availability [k for_rent]})))  ; not already listed
  (effects       (begin-goal {@self let ?prop}))
  (cease-effects (end-goal   {@self let ?prop})))

; TERMINAL step (act_body_purification): AT a known house agency office the letting
; is PROPOSED. list_to_let_act files the for_lease_listing + mints {?prop
; availability for_rent}, which then ceases the {@self let ?prop} intent. The
; readiness is the negation of list_to_let_go's travel gate - standing IN the
; agency office (articles-building of a known house_agency). The act reads ?prop off
; the latched {@self let ?prop} goal (goal-focus), so the propose is label-only to
; match the (act {@self let}) body. Reactive (schedule always): re-proposes each
; decision point while at the office until the listing files and the intent ceases.
(npc-think list_to_let_at_agency
  (schedule always)
  (goal {@self let})
  (role ?agency (believes {?agency isa [k org house_agency]})
                (believes {?agency record ?art}))   ; existence cached, ?art binds at fire
  (when (and (articles-building ?art ?venue)
             (in-building ?venue)))
  (utility 40)
  (effects (propose {@self let})))

; CASE B - knows a house agency, not at its office: travel there. Its incorporation
; articles name the office he calls at (articles-building).
(npc-think list_to_let_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self let})
  (role ?agency (believes {?agency isa [k org house_agency]})
                (believes {?agency record ?art}))   ; existence cached, ?art binds at fire
  (when (and (articles-building ?art ?venue)
             (not (in-building ?venue))))
  (utility 40)
  (effects       (begin-goal {@self enter ?venue}))
  (cease-effects (end-goal   {@self enter ?venue})))

; CASE C - @self knows NO house agency at all: consult the parish incorporations
; register (the orient lane, orient_errand.hs), which mints a mental org object +
; {?org isa ...} belief for EVERY org in town - the only honest channel by which an
; org's identity is learned. The instant a house_agency is learned the (no-role ...)
; fills, this stops, and list_to_let_go takes over. (no-role [k org house_agency])
; reads the SAME per-mind object cache the positive role populates ([k <kind>] is
; sugar for {isa [k <kind>]}).
(npc-think list_to_let_find
  (schedule on-commit)
  (goal {@self let})
  (no-role [k org house_agency])
  (utility 30)
  (effects       (begin-goal {@self orient}))
  (cease-effects (end-goal   {@self orient})))
