; ----------------------------------------------------------------------------
; education_macros.mc - the schooling credential sequence (schooling.mc).
;
; (graduate-from-study): end the ongoing {@self study <curriculum>} interval
; (unforgettable, so the schooling years survive as queryable history) and
; mint / raise the {@self skilled-in <curriculum> <band>} credential - primary
; graduates novice, everything above trained (the band that trips the
; physician / lawyer / scholar identities + the prestige bump). MONOTONIC:
; never downgrades a skill a job pushed higher (comparing the held band's rank
; against the new one). A studied UNIVERSITY SUBJECT (a discipline, not the primary /
; secondary tier) also kindles a standing interest - it maintains the skill
; against atrophy AND unlocks derive_calling (skilled-in >= trained AND an
; interest), the educated-poisoner archetype's root. No-op when not enrolled.
; ----------------------------------------------------------------------------

