# Any human PLAYER
archetype "human_player" (cap 256) (per obs) (raycast-visible) (player) (non-occluder) (occupies-env-grid) (infer-kind-override human player)
{
    "physical_motors"
    "game_role"
    # Lifecycle dates - written by historical sim, surface into interactive.
    "birth_date"
    "death_date"
    "death_cause"
    "age_group"
    "gender"
    "appearance"
    "height"
    "girth"
    "hair_color"
    "eye_color"
    "attractiveness"
    "bank_balance"
    "name"
    "condition"
    "pregnant_when"
    "fatigue"
    "hunger"
    "adrenaline"
    "sleepiness"
    "appetite"
    "sexual_orient"
    # Big Five personality - the ten Big Five Aspect Scale aspects.
    "openness"
    "intellect"
    "industriousness"
    "orderliness"
    "enthusiasm"
    "assertiveness"
    "compassion"
    "politeness"
    "volatility"
    "withdrawal"
    # Dark-tetrad traits - genetic, drive crime motives.
    "narcissism"
    "machiavellianism"
    "psychopathy"
    "sadism"
    # Physical traits (PR-3b 2026-05-25) - genetic, drive method viability.
    "strength"
    "dexterity"
    "agility"
    "endurance"
    "region"
    # The body plan (plan section 18) - same slots as human_npc.
    (struct child "left_hand" [k left_hand] (offset 0 -0.04 0))
    (struct child "right_hand" [k right_hand] (offset 0 0.04 0))
    (struct child "head" [k head] (offset 0 1.6 0))
    (struct child "eyes" [k eye] (offset 0 1.6 0))
    (struct child "mouth" [k mouth] (offset 0 1.55 0.03))
    (struct child "torso" [k torso] (offset 0 1.2 0))
    "pregnant_by"
    "control"
    "obb"
}
