

# Unlike ASK, TELL can be done inside or outside of a conversation.

# These first two rules handle outside the converation:
rule goal-conv-TELL-notAvail
{@self goal {@self TELL ?msg ?audience}}: ?goal
{@self conversation ?myConv}
{?audience conversation !?myConv}
    ->
(maintainProposal {@self keep_near_and_facing ?audience} /absUtil 1000)
(maintainProposal {@self keep_looking_at_part ?audience eyes} /absUtil 1000).


rule goal-conv-TELL-bothAvail
{@self goal {@self TELL ?msg ?audience}}: ?goal
{@self conversation @nothing}
{?audience conversation @nothing}
    ->
(maintainProposal {@self keep_near_and_facing ?audience} /absUtil 1000)
(maintainProposal {@self keep_looking_at_part ?audience eyes} /absUtil 1000).


# This rule handles the case where we want to say something to someone we're currently speaking with
rule conv-TELL-todo
{@self goal {@self TELL ?msg ?audience}:?tell}: ?goal
{@self conversation @something:?myConv}
{?audience conversation ?myConv}
    ->
(maintainBelief {?myConv todo ?tell /causes ?goal}). # add explicit cause because todo is state


rule TELL-proposal
{@self goal {@self TELL ?msg ?audience}}
#(bb_read @self conv_env_cell): ?conv_env_cell
#(overlaps ?conv_env_cell @self 0.8)
#{@self within_reach_of ?audience}
{@self facing ?audience}
{@self keep_looking_at_part ?audience eyes}
(lockRule) # only be telling one thing at a time
    ->
(beginProposal {@self TELL ?msg ?audience}).
#(print [@self proposes to say (nl ?message) because (nl ?causes)]).


rule goal-TELL-outcome
{@self goal {@self TELL ?msg ?audience}}: ?goal
{@self /past TELL ?msg ?audience /causes ~?goal /out?}: ?TELL
    ->
(setOutcome ?goal /from ?TELL).
