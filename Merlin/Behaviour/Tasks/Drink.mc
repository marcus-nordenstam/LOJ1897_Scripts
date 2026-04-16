


rule drink-left-ACTION-proposals
{@self drink ?glass}
{@self hand [k left_hand]:?hand}
{?hand control ?glass}
    ->
(maintainProposal {@self LEFT_ARM_DRINK})
(maintainProposal {@self LEFT_HAND_DRINK})
(maintainProposal {@self OPEN_JAW})
(maintainProposal {@self TILT_BACK_HEAD}).

rule drink-right-ACTION-proposals
{@self drink ?glass}
{@self hand [k right_hand]:?hand}
{?hand control ?glass}
    ->
(maintainProposal {@self RIGHT_ARM_DRINK})
(maintainProposal {@self RIGHT_HAND_DRINK})
(maintainProposal {@self OPEN_JAW})
(maintainProposal {@self TILT_BACK_HEAD}).

rule drink-outcome
{@self drink ?glass}: ?drink
(gt (timeSince /seconds ?drink) 3)
    ->
(setOutcome /succ ?drink).
