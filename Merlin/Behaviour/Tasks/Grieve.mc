
# --- grieve: express grief through hands-to-face, head-hanging, and crying ---

rule grieve-bury-face-proposal
{@self grieve}
    ->
(maintain_proposal {@self RIGHT_ARM_BURY_FACE})
(maintain_proposal {@self LEFT_ARM_BURY_FACE})
(maintain_proposal {@self HANG_HEAD})
(maintain_proposal {@self CRY_EXPR}).
