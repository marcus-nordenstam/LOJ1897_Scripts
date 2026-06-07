# Any human NPC
archetype "human_npc" (cap 4096) (mech obs) (raycast-visible) (sentient) (non-occluder) (occupies-env-grid) (infer-kind-override human nonplayer)
{
    "visual_sensor"
    "sound_sensor"
    "physical_motors"
    "game_role"
    "perform"
    # Lifecycle dates - written by historical sim, surface into interactive.
    "birth_date"
    "death_date"
    "death_cause"
    "age_group"
    "gender"
    "appearance"
    "height"
    "girth"
    "attractiveness"
    # Liquid savings; signed (gambling debt). Accrues yearly, transfers to heir.
    "bank_balance"
    # NPCs learn their own name through self-awareness, not passive perception
    "name"
    "condition"
    "pregnant_when"
    "alertness"
    "sexual_orient"
    # Accumulated intoxication - F3.7 sobriety input.
    "intoxication"
    # Gambling addiction (0..1) - F3.5 sobriety + wealth input.
    "gambling_addiction"
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
    # Parts are not auto-perceived - we perceive specific body-parts below instead
    "parts"
    "left_hand"
    "right_hand"
    "head"
    "eyes"
    "mouth"
    "torso"
    "pregnant_by"
    "control"
    "obb"
}
