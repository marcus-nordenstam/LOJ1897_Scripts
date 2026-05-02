
# --------------------------------------
# Rules for the GIVER in the "give" task
# --------------------------------------

# To give, you must have it
rule give-proposal-get-thing
{@self give ?thing ?recipient}
{@self hand ?hand}
{?hand control !?thing}
    ->
(maintain_proposal {@self get ?thing}).


# If you have it, you must be close enough to touch the recipient
rule give-goal-within-reach-of-recipient
{@self give ?thing ?recipient}
{@self hand ?hand}
{?hand control ?thing}
    ->
(maintain_proposal {@self keep_near_and_facing ?recipient} (des abs_util 1000)).


rule give-proposal-offer
{@self give ?thing ?recipient}
{@self hand ?hand}
{?hand control ?thing}
{@self within_reach_of ?recipient}
{@self facing ?recipient}
(realis ?thing)
    ->
(maintain_proposal {@self OFFER ?thing ?recipient}).


# ------------------------------------------
# Rules for the RECIPIENT in the "give" task
# ------------------------------------------

rule goal-possess-receive-proposal
# If I want to possess a thing
{@self goal {@self possess ?thing}}
# and someone is offering me that thing
{?giver OFFER ?thing @self}: ?offer
    ->
# then get it
(maintain_proposal {@self receive ?thing ?giver}): ?proposal
(add_causes ?proposal ?offer). # the offer is not a self-action, so it won't be automatically added as a cause


/*
# If I want a hypothetical document of a specific kind
rule 
{@self goal {@self possess [k document]:?doc}}
# and someone is offering me that kind of document
{?giver OFFER ?offeredDoc @self}
{?offeredDoc isa [k document]:?specificKind}
# which I have never read
(none {@self /succ read ?offeredDoc})
(irrealis ?doc)
    ->
# then read it to see if it is the actual document I want
# (the read task will cause me to take it before reading)
(maintain_proposal {@self read ?offeredDoc}).
*/

# ------------------------------------------
# Giving outcomes
# ------------------------------------------

# From the giver's pov
rule give-outcome-giver
{@self /ever give ?thing ?recipient}: ?give
{@self /succ OFFER ?thing ?recipient /causes ~?give}: ?offer
#{?recipient /succ TAKE ?thing /causes ~?offer}
    ->
(set_outcome ?give /succ)
(fire_and_forget).

# From the observer's pov
rule give-outcome-observer
{!@self:?giver /succ OFFER ?thing ?recipient}: ?offer
{?recipient /succ take ?thing /causes ~?offer}
    ->
(begin_belief {?giver give ?thing ?recipient /momentary}): ?give
(set_outcome ?give /succ)
(fire_and_forget).


/*
# If you have it, then strive to be face-to-face with the recipient
rule 
{@self give ?thing ?recipient}
{@self control ?thing}
    ->
{@self goal {.. maintain {.. face_to_face at ?recipient}} +1000}.

# If you are giving to a player, then you must be face-to-face with them (so they can see what you are doing)
rule 
{@self give ?thing ?player}
{@self control ?thing}
{?player role player}
{@self face_to_face at ?player}
    ->
{propose() {@self OFFER ?thing ?player}}.

# If you are giving to an NPC, then you just have to be in reaching distance
rule 
{@self give ?thing ?npc}
{@self control ?thing}
{?npc role nonplayer}
{@self at ?npc}
    ->
{propose() {@self OFFER ?thing ?npc}}.
*/

