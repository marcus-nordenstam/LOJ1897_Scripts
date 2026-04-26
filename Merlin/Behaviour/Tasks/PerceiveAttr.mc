
# Perceive a physical attribute on a physical object


# First of all, in order to perceive anything on an object, you'll
# have to be close enough to observe/hear/smell it
rule perceive-attr-keep-near-and-facing-proposal
{@self perceive_attr ?thing ?attr}: ?perceive_attr
    ->
(maintain_proposal {@self keep_near_and_facing ?thing} (abs_util 1000)).


# If you are close enough, and you have perceived the object, then
# we can propose to perform the actual PERCEIVE_ATTR action which
# lets us perceive the specific attribute on the object.
rule perceive-attr-action-proposal
{@self perceive_attr ?thing ?attr}: ?perceive_attr
(observed ?thing) # You can't actually perceive any attr on ?thing until you have seen ?thing
    ->
(maintain_proposal {@self PERCEIVE_ATTR ?thing ?attr}).

rule perceive-attr-outcome
{@self /ever perceive_attr ? ? /noOut}: ?perceive_attr
{@self /past PERCEIVE_ATTR ? ? /causes ~?perceive_attr}: ?PERCEIVE_ATTR
    ->
(set_outcome ?perceive_attr (outcome ?PERCEIVE_ATTR)).
