
# --- grieve: express grief through hands-to-face, head-hanging, and crying ---

rule grieve-bury-face-proposal
{@self grieve}
    ->
(maintainProposal {@self RHAND_BURY_FACE})
(maintainProposal {@self LHAND_BURY_FACE})
(maintainProposal {@self HANG_HEAD})
(maintainProposal {@self CRY_EXPR}).
