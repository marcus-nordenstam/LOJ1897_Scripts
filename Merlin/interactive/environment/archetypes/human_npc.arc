# Any human NPC
archetype "human_npc" [4096] /obs /raycast_visible /sentient /non_occluder /occupies_env_grid /infer_kind_override human nonplayer
{
    "visual_sensor"
    "sound_sensor"
    "physical_motors"
    "role"
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
    # NPCs learn their own name through self-awareness, not passive perception
    "name"
    "condition"
    "pregnant_when"
    "alertness"
    "sexual_orient"
    # Accumulated intoxication - F3.7 sobriety input.
    "intoxication"
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
    "region"
    # Parts are not auto-perceived — we perceive specific body-parts below instead
    "parts"
    "left_hand"
    "right_hand"
    "head"
    "eyes"
    "mouth"
    "pregnant_by"
    "control"
    "obb"
}
