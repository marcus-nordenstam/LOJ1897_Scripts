
# --- grieve: express grief through hands-to-face, head-hanging, and crying ---

rule grieve-bury-face-proposal
{@self grieve}
    ->
(maintainProposal {@self RIGHT_ARM_BURY_FACE})
(maintainProposal {@self LEFT_ARM_BURY_FACE})
(maintainProposal {@self HANG_HEAD})
(maintainProposal {@self CRY_EXPR}).
