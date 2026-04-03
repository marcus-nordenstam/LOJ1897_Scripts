


rule drink-left-reach-proposal
{@self drink ?glass}
{@self hand [k leftHand]:?hand}
{?hand control ?glass}
{@self mouth ?mouth}
    ->
(maintainProposal {@self LOOK_AT ?glass})
(maintainProposal {@self LEFT_REACH_FOR ?mouth}).


rule drink-right-reach-proposal
{@self drink ?glass}
{@self hand [k rightHand]:?hand}
{?hand control ?glass}
{@self mouth ?mouth}
    ->
(maintainProposal {@self LOOK_AT ?glass})
(maintainProposal {@self RIGHT_REACH_FOR ?mouth}).


rule drink-outcome
{@self drink ?glass}: ?drink
{@self mouth ?mouth}
{@self /past RIGHT_REACH_FOR ?mouth /out? /causes ~?drink}: ?REACH
    ->
(setOutcome ?drink /from ?REACH)
