
# --- grieve: express grief through hands-to-face, head-hanging, and crying ---
# ARM_BURY_FACE is sided on its target slot; firing it twice with [k left] and
# [k right] occupies left_arm and right_arm motors simultaneously.
rule grieve-bury-face-proposal
{@self grieve}
    ->
(maintain_proposal {@self ARM_BURY_FACE [k right]})
(maintain_proposal {@self ARM_BURY_FACE [k left]})
(maintain_proposal {@self HANG_HEAD})
(maintain_proposal {@self CRY_EXPR}).
