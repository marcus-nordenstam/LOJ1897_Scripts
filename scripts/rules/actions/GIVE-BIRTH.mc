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
; who bore it. It gets no name - CHRISTEN gives it - and no nationality, class or
; home: those are beliefs, and an action may not read beliefs (action-purity).
; The mother's own beliefs about the child - her bond, the end of her pregnancy -
; are the give-birth task's (tasks/give-birth-task.mc), which reads the child off
; this act's `created`.
;
; Who ELSE learns of the child is not settled here either. The newborn knows its
; own parents; its mother introduces it to her other children; every other
; relative learns the ordinary way, by meeting it or being told. The newborn's mind is
; seeded the way world-gen seeds a founder's - (enter-mind ?baby), the one seam
; that writes a mind other than the actor's - before it has ever deliberated.
;
; Delivering ENDS the pregnancy's physiology - pregnant-when / pregnant-by.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")
(include "../../funcs/human-traits.mc")
(include "../../funcs/age.mc")
(include "../../funcs/money.mc")

(action {@self GIVE-BIRTH ?father}:?GIVE-BIRTH
  (motor all)
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
    (seed-npc-habits ?baby)
    (set-attr ?baby parentless 0)
    (set-attr ?baby birth-date (create-date (time year) (time month) (time day)))
    (start-aging ?baby)
    (seed-carrying-cash-pile ?baby)
    ; The parents are read off the act's abs twin: inside the baby's mind the
    ; mother's own symbols name nothing.
    (enter-mind ?baby)
    ; The body is the baby's own - (private) - so it is seeded from inside its mind.
    (seed-human-vitals @self)
    (observe ?xgive-birth.subject): ?known-mother
    (observe ?xgive-birth.target): ?known-father
    (begin-belief {@self mother ?known-mother})
    (begin-belief {@self father ?known-father})
    (exit-mind)
    ; She sees the child she bore, and the give-birth task takes it from there.
    (observe ?baby): ?known-baby
    (bb-write ?GIVE-BIRTH created ?known-baby)
    (set-attr @self pregnant-when @nothing)
    (set-attr @self pregnant-by @nothing)
    (set-outcome ?GIVE-BIRTH /succ)))
