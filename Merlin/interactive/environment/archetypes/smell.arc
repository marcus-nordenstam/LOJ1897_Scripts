# Any smell - the olfactory twin of sound. A smell is a transient ENTITY with its
# own bounds, emitted into a space and perceived by nose, NOT an attr on the thing
# that reeks: two people in a room smell the same one, and it outlives its source
# (the fart persists after the man leaves). Mirrors sound.arc; the difference is
# only the sense it reaches.
archetype "smell" (cap 512) (non-occluder) (per smell)
{
    # What produced it - the twin of a sound's create-action, so a nose that finds
    # a smell can reason about the act behind it.
    (attr "create-action")
    (spatial bounds)
}
