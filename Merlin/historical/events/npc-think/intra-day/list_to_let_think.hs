; ----------------------------------------------------------------------------
; list_to_let - the SUPPLY side of the property market (per-NPC replacement for
; the omniscient world-act/landlord_duties.hs). An owner advertises his OWN
; vacant residential building to let, from his OWN knowledge - no world scan.
;
; The annual disposition (year-think february, a month before the buyers come
; looking in march) mints a standing intent {@self let ?prop} for each vacant
; dwelling he owns. Vacancy is read entirely from his own beliefs (the
; knowledge-honest signal): a dwelling he owns, that is-a residential, that is
; NOT his home, that he holds no tenant belief for, and that he has not already
; listed. Inheritance deeds him the dwelling ({@self own}); a tenant's death /
; emigration ends his {?prop tenant}, so the vacancy surfaces without a scan.
;
; Routing then walks him to a house agency, where list_to_let_act (npc-act) files
; the for_lease_listing and mints {?prop availability for_rent} - the durable "to
; let" signal landlord_estate.hs already reads. It mirrors the worship lane's
; three-case structure so the supply never goes dormant merely because @self has
; not yet learned which orgs are house agencies:
;   KNOWS an agency, not there -> list_to_let_go   (travel to its office).
;   AT a known agency          -> list_to_let_dwell (re-affirm -> the listing act).
;   KNOWS no agency at all      -> list_to_let_find  (orient to learn one).
;
;   list_to_let       : year-think - mint the standing {@self let ?prop} intent.
;   list_to_let_go    : hold the intent, knows an agency, not there -> travel there.
;   list_to_let_dwell : hold the intent, AT a known agency -> re-affirm the leaf so
;                       it promotes to the listing act.
;   list_to_let_find  : hold the intent, knows NO agency -> orient (learn one).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think list_to_let
  (year-think february)
  (role @self (adult @self))
  ; His OWN vacant residential holdings (object-cache role over his beliefs).
  (role ?prop (believes {@self own ?prop})
              (believes {?prop isa [k residential_building]})
              (not (believes {@self home ?prop}))            ; not where he lives
              (not (believes {?prop tenant ?}))              ; no sitting tenant
              (not (believes {?prop availability [k for_rent]})))  ; not already listed
  (first-fire-effects (begin-goal {@self let ?prop})))

; CASE B - knows a house agency, not at its office: travel there. Its incorporation
; articles name the office he calls at (articles-building).
(npc-think list_to_let_go
  (short-term-think)
  (goal {@self let})
  (role ?agency (believes {?agency isa [k org house_agency]})
                (believes {?agency record ?art}))   ; existence cached, ?art binds at fire
  (when (and (articles-building ?art ?venue)
             (not (in-building ?venue))))
  (utility 40)
  (cont-fire-effects (go-into ?venue)))

; CASE A - AT a known agency: re-affirm the standing intent with this think's
; utility so, with the go sub-goal spent, the let goal is the leaf and promotes to
; the act (the latched {@self let ?prop} carries the target; the act reads it via
; goal-focus).
(npc-think list_to_let_dwell
  (short-term-think)
  (goal {@self let})
  (role ?agency (believes {?agency isa [k org house_agency]})
                (believes {?agency record ?art}))   ; existence cached, ?art binds at fire
  (when (and (articles-building ?art ?venue)
             (in-building ?venue)))
  (utility 40)
  (cont-fire-effects (begin-goal {@self let})))

; CASE C - @self knows NO house agency at all: consult the parish incorporations
; register (the orient lane, orient_errand.hs), which mints a mental org object +
; {?org isa ...} belief for EVERY org in town - the only honest channel by which an
; org's identity is learned. The instant a house_agency is learned the (no-role ...)
; fills, this stops, and list_to_let_go takes over. (no-role [k org house_agency])
; reads the SAME per-mind object cache the positive role populates ([k <kind>] is
; sugar for {isa [k <kind>]}).
(npc-think list_to_let_find
  (short-term-think)
  (goal {@self let})
  (no-role [k org house_agency])
  (utility 30)
  (cont-fire-effects (excl-goal {@self orient})))
