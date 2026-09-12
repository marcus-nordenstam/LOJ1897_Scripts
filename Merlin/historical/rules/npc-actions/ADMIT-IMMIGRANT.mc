; ----------------------------------------------------------------------------
; admit-immigrant (npc-action) - a civic gatekeeper admits ONE newcomer to the
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

(npc-action {@self ADMIT-IMMIGRANT ?office}
  (duration (admission_minutes))
  (effects
    (env-entities [k building rowhouse]): ?homes
    (count ?homes): ?n
    (check (> ?n 0))
    (nth ?homes (random-int 0 (- ?n 1))): ?imm-home
    (make-human ?imm-home [k class-situation lower]): ?newcomer
    (check (substantial ?newcomer))
    (set-outcome {@self ADMIT-IMMIGRANT ?office} /succ)))
