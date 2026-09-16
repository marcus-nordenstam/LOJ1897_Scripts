; ----------------------------------------------------------------------------
; calling (classifier). A domain the NPC is BOTH competent in AND passionate about
; becomes their calling - the skill-plus-interest alignment. `calling` is
; (tar domain @excl) and permanent: the absence gate closes the moment one is
; minted, and interest-lapse cannot shed a skill-backed interest, so the alignment
; that produced it persists. Read by confide-think (the private self-fact an NPC
; shares with a friend).
;
; COMPETENT means the pipeline-emitted {@self skill-level [k <domain>] [k <rung>]}
; sits at `competent` or above. That is this port's one judgement call: the C++
; fold required `trained`, the middle rung of the retired 3-rung competence_level
; ladder (novice/trained/expert); `competent` is the same position on the 4-rung
; skill_rung ladder (beginner/competent/proficient/virtuoso). Retune here if the
; rung distribution says otherwise.
;
; Deterministic - no chance roll: the interest + competence alignment is itself the
; rare, selective gate. Where several domains qualify at once, @excl keeps one.
; ----------------------------------------------------------------------------

(npc-think classify_calling
  (cooldown 1 m)
  (rng-stream behaviour)

  (role @self -{@self calling ?})

  (role ?domain {@self interest ?domain}
                (or {@self skill-level ?domain [k competent]}
                    {@self skill-level ?domain [k proficient]}
                    {@self skill-level ?domain [k virtuoso]}))

  (effects
    (begin-belief {@self calling ?domain})))
