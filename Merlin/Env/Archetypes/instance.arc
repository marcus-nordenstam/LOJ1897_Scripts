# Instanced entities.
# NOTE that attrs listed here override the same attrs from the prototype.
archetype "instance" [1] /obs
{
    "isa"           kind                                /kind

    # The prototype entity
    "prototype"     entity          /prototype
    
    # If the instance is currently in a stack, which one
    "inStack"       entity "stack"  /inStack
    
    # If the instance is NOT in a stack, then this gives its bounds
    "obb"           obb             /spatialBounds
}
