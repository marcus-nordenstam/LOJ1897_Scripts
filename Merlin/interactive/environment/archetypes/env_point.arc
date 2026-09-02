# env-point: nav waypoints / spawnpoints (points for NPC navigation + spawning).
# Distinct from `space` (occupiable interior/exterior regions) and from the
# `location` whereabouts belief-label.
archetype "env-point" (cap 256) (per obs) (always-visible) (non-occluder) (sector-coverage)
{
    (spatial bounds)
}
