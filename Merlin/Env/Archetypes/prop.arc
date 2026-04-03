# Any object that is potentially mobile
archetype "prop" [1024] /obs
{
    "isa"           kind                                /kind               /passivePercept
    "date"          date                                /date
    "color"         str                                                     /passivePercept
#   "material"      str                                                     /passivePercept

    # Some props are broken, some are whole etc
    "condition"     str                                                     /passivePercept

    # Maybe some props have an actual name, though rare
    "name"          name                                /name               /passivePercept

    # Some props like documents and books contain writings.
    # The writings are expressed using a Merlin pattern holding a list of messages.
    # The list is given in sections, where is section is itself a list, starting with the
    # categorical kind of the section, followed by sentences.  
    # For example:  (msg [ [[k title] {book title foo} {book by bar}] 
    #                    [[k chapter] ...]])
    "writings"      pattern                                                 /read

    # ENTITY attrs
    "parts"         entity [6] /label "part"            /children           /passivePercept
    "in"            entity [6] "structure" "space"      /spatialContainment /imperceptible
    # The entity currently controlling the position of this prop (if any)
    "controlledBy"  entity                              /controlledBy
    # How hard the entity is being gripped. 0=loose, 1=hard
    "controlForce"  int                                                     /imperceptible
    # If this is the controlling entity, then this holds what is being controlled
    "control"       entity [4]                          /control            /passivePercept
    # This gives the stack the prop is in, if any.
    # If the prop is NOT in a stack, this is set to @nothing.
    "inStack"       entity "stack"                      /inStack

    # If the prop is NOT in a stack, then this gives its bounds - which are observable
    # If the prop is in a stack, however, this value will be set to @nothing
    "obb"           obb                                 /spatialBounds      /passivePercept
}
