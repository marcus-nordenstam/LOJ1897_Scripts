; ----------------------------------------------------------------------------
; give-birth (npc-action) - the physical act of delivery: a woman carrying a
; pregnancy bears the child of herself and ?father, in the room she is standing
; in. The THIRD way a human comes into being, beside the founder pass and the
; immigrant arrival, and the only one with a lineage - so it seeds the SAME
; genetic layer those do (human-traits.hs), with both parents supplied instead of
; neither. That is the whole difference between being born and being minted.
;
; The target is the father because the proposing think already read him off her
; pregnancy: the body does no deliberation, it bears the child it is told whose
; it is.
;
; PHYSICAL ONLY. A newborn gets a body, its parents' traits and the knowledge of
; who bore it. It gets no name, no nationality, no class and no home - those are
; beliefs, an npc-action may not read beliefs (action-purity), and an act pattern
; carries two fields, which is one short of what that inheritance needs. They are
; the parents' job in their own rung, where their own beliefs are readable.
;
; Who ELSE learns of the child is not settled here either. The newborn knows its
; own parents (it is born of them) and the mother knows her child (she bore it);
; every other relative learns the ordinary way, by meeting the baby or being told
; about it. There is no write into a third mind anywhere in this body.
;
; Delivering ENDS the pregnancy - the pregnant-when / pregnant-by physiology and
; the {@self pregnant ?} self-belief that gated her out of re-conceiving - so she
; is eligible again.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")
(include "../../funcs/human-traits.mc")

(npc-action {@self GIVE-BIRTH ?father}
  (duration (birth_labour_minutes))
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
    (set-attr ?baby birth-date (create-date (year) (month) (day)))
    ; The newborn's own kin beliefs, minted IN the mind being created - the same
    ; thing make-human does for a founder, and the only mind this body writes to
    ; besides the actor's own. The two-arg form externalizes each field and
    ; observes it into the holder, so the baby meets its parents on the way in.
    (begin-belief ?baby {?baby mother @self})
    (begin-belief ?baby {?baby parent @self})
    (begin-belief ?baby {?baby father ?father})
    (begin-belief ?baby {?baby parent ?father})
    ; The mother's own belief about the child she just bore. SEE it first: a
    ; belief field converts into the believer's realm, so an object the mind has
    ; never met lands as @fail.
    (observe ?baby): ?known-baby
    (begin-belief {@self child ?known-baby})
    ; The pregnancy is over.
    (set-attr @self pregnant-when @nothing)
    (set-attr @self pregnant-by @nothing)
    (end-belief {@self pregnant ?father})
    (set-outcome {@self GIVE-BIRTH ?father} /succ)))
