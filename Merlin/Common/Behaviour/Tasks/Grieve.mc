
# --- grieve: express grief through hands-to-face and head-hanging ---
# Each sub-action runs on a separate motor so that conversation (or other
# higher-utility tasks) can override individual motors independently.
# e.g. during conversation, HANG_HEAD loses to LOOK_AT on the head motor,
# but hands stay in grief pose.

rule grieve-bury-face-proposal
{@self grieve}
    ->
(maintainProposal {@self RHAND_BURY_FACE})
(maintainProposal {@self LHAND_BURY_FACE})
(maintainProposal {@self HANG_HEAD}).
