# Ring-fingers only - 2 per human; capacity scales with hand cap.
archetype "finger" (cap 8192) (per obs) (non-occluder)
{
    "struct_parent"
    "wear"
    "control"
    "obb"
    # PR-evi-A 2026-05-25 - per-body-part evidence attrs.
    "wounds"
    "stains"
    "marks"
}
