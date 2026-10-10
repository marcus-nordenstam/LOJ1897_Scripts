; ----------------------------------------------------------------------------
; give-birth (action) - the physical act of delivery: a woman carrying a
; pregnancy bears the child of herself and ?father, in the room she is standing
; in. The THIRD way a human comes into being, beside the founder pass and the
; immigrant arrival, and the only one with a lineage - so it seeds the SAME
; genetic layer those do (human-traits.mc), with both parents supplied instead of
; neither. That is the whole difference between being born and being minted.
;
; The target is the father because the proposing think already read him off her
; pregnancy: the body does no deliberation, it bears the child it is told whose
; it is.
;
; PHYSICAL ONLY. A newborn gets a body, its parents' traits and the knowledge of
; who bore it. It gets no name, no nationality, no class and no home - those are
; beliefs, an action may not read beliefs (action-purity), and an act pattern
; carries two fields, which is one short of what that inheritance needs. They are
; the parents' job in their own rung, where their own beliefs are readable.
;
; Who ELSE learns of the child is not settled here either. The newborn knows its
; own parents and the mother knows her child; every other relative learns the
; ordinary way, by meeting the baby or being told about it. The newborn's mind is
; seeded the way world-gen seeds a founder's - (enter-mind ?baby), the one seam
; that writes a mind other than the actor's - before it has ever deliberated.
;
; Delivering ENDS the pregnancy - the pregnant-when / pregnant-by physiology and
; the {@self pregnant ?} self-belief that gated her out of re-conceiving - so she
; is eligible again.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")
(include "../../funcs/human-traits.mc")
(include "../../funcs/age.mc")
(include "../../funcs/money.mc")

(action {@self GIVE-BIRTH ?father}:?GIVE-BIRTH
  (motor body legs)
  (xaction ?xgive-birth)
  (presentation
    (preroll 0.0) (in 0.5) (out 0.5))
  (duration (seconds (birth_labour_minutes) min))
  (effects
    ; Born where the mother is. A woman with no room under her cannot deliver -
    ; there would be nowhere to put the child.
    (spatial @self space /env): ?room
    (check (substantial ?room))
    (table-sample-weighted gender_dist value weight): ?gender
    (create-entity [k human] ?room): ?baby
    (check (substantial ?baby))
    (set-attr ?baby gender ?gender)
    (set-attr ?baby game-role [k nonplayer])
    (seed-human-genetics ?baby ?gender @self ?father)
    (seed-handwriting ?baby @nothing @self)
    (seed-human-vitals ?baby)
    (seed-npc-habits ?baby)
    (set-attr ?baby parentless 0)
    (set-attr ?baby birth-date (create-date (time year) (time month) (time day)))
    (start-aging ?baby)
    (seed-carrying-cash ?baby)
    ; The parents are read off the act's abs twin: inside the baby's mind the
    ; mother's own symbols name nothing.
    (enter-mind ?baby)
    (observe ?xgive-birth.subject): ?known-mother
    (observe ?xgive-birth.target): ?known-father
    (begin-belief {@self mother ?known-mother})
    (begin-belief {@self parent ?known-mother})
    (begin-belief {@self father ?known-father})
    (begin-belief {@self parent ?known-father})
    (exit-mind)
    ; The mother's own belief about the child she just bore. SEE it first: a
    ; belief field converts into the believer's realm, so an object the mind has
    ; never met lands as @fail.
    (observe ?baby): ?known-baby
    (begin-belief {@self child ?known-baby})
    ; The pregnancy is over.
    (set-attr @self pregnant-when @nothing)
    (set-attr @self pregnant-by @nothing)
    (end-belief {@self pregnant ?father})
    (set-outcome ?GIVE-BIRTH /succ)))
