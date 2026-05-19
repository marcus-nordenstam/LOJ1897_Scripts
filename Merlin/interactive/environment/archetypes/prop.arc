# Any object that is potentially mobile
archetype "prop" [1024] /obs /occupies_env_grid /non_occluder
{
    "birth_date"
    "color"
    # Some props are broken, some are whole, etc.
    "condition"
    # Maybe some props have an actual name, though rare
    "name" /auto_percept
    "writings"
    "parts" /auto_percept
    "controlled_by"
    "control_force"
    "control"
    "in_stack"
    # If prop is in a stack, obb is set to _
    "obb"
}
