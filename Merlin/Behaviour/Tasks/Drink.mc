


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


# Look at all rules involving left-right hand, now that we have | we can perhaps unify many of them

# Eeach drink task should trigger a new action: INGEST
#   INGEST may modify the physical state of the actor: hunger, thirst, intoxication
#   if the entity being ingested is a fluid:
#       reduce fluid_amount attr on the fluid
#       if fluid_amount drops to 0, destroy the ingested entity
