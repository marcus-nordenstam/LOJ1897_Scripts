# Any human NPC
archetype "human-npc" (cap 4096) (per obs) (raycast-visible) (sentient) (non-occluder) (occupies-env-grid) (infer-kind-override human nonplayer)
{
    # Placement participation (plan section 18): which spatial relations this
    # archetype takes part in - the write seams validate both ends.
    (spatial grip)
    (spatial space)
    (attr "visual-sensor")
    (attr "sound-sensor")
    (attr "physical-motors")
    (attr "game-role")
    (attr "perform")
    # Lifecycle dates - written by historical sim, surface into interactive.
    (attr "birth-date")
    (attr "death-date")
    (attr "death-cause")
    # 1 = created parent-less (founder / immigrant); 0 = born in-sim with parents.
    (attr "parentless")
    (attr "age-group")
    # Perceptible life-stage + its +/-1 proximity window (see common.arc).
    (attr "age-band")
    (attr "age-span")
    (attr "gender")
    (attr "appearance")
    (attr "height")
    (attr "girth")
    (attr "hair-color")
    (attr "eye-color")
    (attr "attractiveness")
    # NPCs learn their own name through self-awareness, not passive perception
    (attr "name")
    (attr "condition")
    (attr "awareness")
    (attr "internment")
    (attr "pregnant-when")
    (attr "sexual-orient")
    # Continuous physical tiredness (0..2) - the rest lane reads it; the sleep
    # act's completion reduces it, waking time accrues it (imperceptible).
    (attr "fatigue")
    (attr "hunger")
    # Fight-or-flight surge (0..1) + the adrenaline-masked drives it derives:
    # sleepiness = fatigue*(1-adrenaline), appetite = hunger*(1-adrenaline). The rest
    # / meal lanes read sleepiness / appetite so a combatant does not doze / break to
    # eat mid-fight, then crashes when the surge fades (update_physiology owns them).
    (attr "adrenaline")
    (attr "sleepiness")
    (attr "appetite")
    # Emigration marker (0/1) - set per-NPC, swept zero-role (mark-then-sweep).
    (attr "emigrating")
    # Accumulated intoxication - F3.7 sobriety input.
    (attr "intoxication")
    # Gambling addiction (0..1) - F3.5 sobriety + wealth input.
    (attr "gambling-addiction")
    # Big Five personality - the ten Big Five Aspect Scale aspects.
    (attr "openness")
    (attr "intellect")
    (attr "industriousness")
    (attr "orderliness")
    (attr "enthusiasm")
    (attr "assertiveness")
    (attr "compassion")
    (attr "politeness")
    (attr "volatility")
    (attr "withdrawal")
    # Dark-tetrad traits - genetic, drive crime motives.
    (attr "narcissism")
    (attr "machiavellianism")
    (attr "psychopathy")
    (attr "sadism")
    # Physical traits (PR-3b 2026-05-25) - genetic, drive method viability.
    (attr "strength")
    (attr "dexterity")
    (attr "agility")
    (attr "endurance")
    (attr "region")
    # The body plan (plan section 18): named singleton slots, builder-created at
    # the declared local offsets (decl order = creation order). A hand's own
    # archetype declares its ring-finger, so it rides along.
    (struct child "left-hand" [k left-hand] (offset 0 -0.04 0))
    (struct child "right-hand" [k right-hand] (offset 0 0.04 0))
    (struct child "head" [k head] (offset 0 1.6 0))
    (struct child "eyes" [k eye] (offset 0 1.6 0))
    (struct child "mouth" [k mouth] (offset 0 1.55 0.03))
    (struct child "torso" [k torso] (offset 0 1.2 0))
    (attr "pregnant-by")
    # The NPC's current SPACE (room / exterior-space). Perceptible + auto-percept
    # (the universal `location` attr): relocate writes it on every move, the NPC
    # self-perceives it, and co-presence is read straight off it - no belief dig.
    # (4.13 movement substrate.)
    (spatial bounds)
}
