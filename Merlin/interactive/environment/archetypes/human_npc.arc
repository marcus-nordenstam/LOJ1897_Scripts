# Any human NPC
archetype "human_npc" (cap 4096) (per obs) (raycast-visible) (sentient) (non-occluder) (occupies-env-grid) (infer-kind-override human nonplayer)
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
    # 1 = created parent-less (founder / immigrant); 0 = born in-sim with parents.
    "parentless"
    "age_group"
    # Perceptible life-stage + its +/-1 proximity window (see common.arc).
    "age_band"
    "age_span"
    "gender"
    "appearance"
    "height"
    "girth"
    "hair_color"
    "eye_color"
    "attractiveness"
    # Liquid savings; signed (gambling debt). Accrues yearly, transfers to heir.
    "bank_balance"
    # NPCs learn their own name through self-awareness, not passive perception
    "name"
    "condition"
    "pregnant_when"
    "sexual_orient"
    # Continuous physical tiredness (0..2) - the rest lane reads it; the sleep
    # act's completion reduces it, waking time accrues it (imperceptible).
    "fatigue"
    "hunger"
    # Fight-or-flight surge (0..1) + the adrenaline-masked drives it derives:
    # sleepiness = fatigue*(1-adrenaline), appetite = hunger*(1-adrenaline). The rest
    # / meal lanes read sleepiness / appetite so a combatant does not doze / break to
    # eat mid-fight, then crashes when the surge fades (update_physiology owns them).
    "adrenaline"
    "sleepiness"
    "appetite"
    # Emigration marker (0/1) - set per-NPC, swept zero-role (mark-then-sweep).
    "emigrating"
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
    # The body plan (plan section 18): named singleton slots, builder-created at
    # the declared local offsets (decl order = creation order). A hand's own
    # archetype declares its ring_finger, so it rides along.
    (struct child "left_hand" [k left_hand] (offset 0 -0.04 0))
    (struct child "right_hand" [k right_hand] (offset 0 0.04 0))
    (struct child "head" [k head] (offset 0 1.6 0))
    (struct child "eyes" [k eye] (offset 0 1.6 0))
    (struct child "mouth" [k mouth] (offset 0 1.55 0.03))
    (struct child "torso" [k torso] (offset 0 1.2 0))
    "pregnant_by"
    "control"
    # The NPC's current SPACE (room / exterior_space). Perceptible + auto-percept
    # (the universal `location` attr): relocate writes it on every move, the NPC
    # self-perceives it, and co-presence is read straight off it - no belief dig.
    # (4.13 movement substrate.)
    "location"
    "obb"
}
