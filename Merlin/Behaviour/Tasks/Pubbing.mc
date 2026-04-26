

# Pub patron behaviour.

# If I have a beer in my hand, drink it
rule pubbing-drink-beer-proposal
{@self pubbing}
{@self hand ?hand}
{?hand control [k drinking_glass]:?glass}
{?glass control [k beer]}
    -> /cont-interval 8 2
(beginProposal {@self drink ?glass}).


# If I don't, order one
rule pubbing-order-beer-proposal
{@self pubbing}
{?bartender perform [k bartending] ?pub}
(in @self ?pub)
(none {@self hand.control.control [k beer]})
    ->
(beginProposal {@self order [k beer] ?bartender}).


# First, find a spot at the bar where you can
# talk to the bartender
rule pubbing-order-beer-claim-spot-at-bar
{@self pubbing}
{?bartender perform [k bartending] ?pub}
{@self order [k beer] ?bartender}
{?pub part [k bar_counter]:?bar_counter}
(bb_public_none @self talk_cell)
(claim_env_cell /in_front ?bar_counter): ?talk_cell
    ->
(beginGoal {@self talk_to ?bartender})
(bb_public_write @self talk_cell ?talk_cell).


# Wait for the bartender
rule pubbing-order-beer-wait-at-bar
{@self pubbing}
{@self order [k beer] ?bartender}: ?order
{?bartender perform [k bartending] ?pub}
{?pub part [k bar_counter]:?bar_counter}
(bb_public_read @self talk_cell): ?talk_cell
(overlaps ?talk_cell @self)
    ->
#(beginBelief {@self expect_question ?bartender /causes ?order})
(bb_public_write @self wants_drink @true)
#(maintainProposal {@self TURN_TO ?bar_counter})
(maintainProposal {@self keep_looking_at_part ?bartender eyes}).


# When the bartender serves me a beer, take it
rule pubbing-order-beer-take-beer
{@self pubbing}
{@self order [k beer] ?bartender}: ?order
{?bartender perform [k bartending] ?pub}
(bb_public_read @self served_beer_cell): ?beer_cell
(env_cell_occupier [k drinking_glass] ?beer_cell): ?beer_glass
    ->
(setOutcome /succ {@self goal {@self talk_to ?bartender}})
(beginProposal {@self take ?beer_glass}).


# Once I've ordered and taken the beer,
# I'm done being served and I release my slot to others
rule pubbing-order-beer-unclaim-spot-at-bar
{@self pubbing}
{?bartender perform [k bartending] ?pub}
{@self order [k beer] ?bartender}: ?order
{@self /succ take ?beer /causes ~?order}
#(bb_public_read @self talk_cell): ?talk_cell
    ->
#(unclaim_env_cell ?talk_cell)
#(bb_public_clear @self talk_cell)
(bb_public_clear @self served_beer_cell)
(bb_public_clear @self wants_drink)
(setOutcome ?order /succ).


