; ----------------------------------------------------------------------------
; admit-immigrant (action) - a civic gatekeeper admits ONE newcomer to the
; parish, at ?office, the public premises he holds his post at. The SECOND way a
; human comes into being: minted by the shared (make-human) func, so a newcomer
; carries the same genetic and mental layers a founder does.
;
; Parentless FOR NOW. An arrival ought to have a mother and a father he left
; behind, which is what (give-birth ..) exists to give him; until that is built
; he is minted the founder way and the lineage stays empty.
;
; Finding him a roof is an env read, which is what an action is licensed for and
; what kept this out of the think: the gatekeeper decides to admit someone, the
; world decides which house is standing empty. The pick is RANDOM - taking the
; first rowhouse on the register lodged every newcomer who ever arrived in the
; same building.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(action {@self ADMIT-IMMIGRANT ?office}:?ADMIT-IMMIGRANT
  (motor body legs)
  (duration (seconds (admission_minutes) min))
  (effects
    (env-entities [k rowhouse]): ?homes
    (count ?homes): ?n
    (check (> ?n 0))
    (nth ?homes (random-int 0 (- ?n 1))): ?imm-house
    (spatial ?imm-house parts [k unit] /env): ?imm-units
    (check (not (empty ?imm-units)))
    (nth ?imm-units (random-int 0 (- (count ?imm-units) 1))): ?imm-home
    (table-sample-weighted gender_dist value weight): ?gender
    (make-human ?imm-home [k lower] ?gender): ?newcomer
    (check (substantial ?newcomer))
    (set-outcome ?ADMIT-IMMIGRANT /succ)))
