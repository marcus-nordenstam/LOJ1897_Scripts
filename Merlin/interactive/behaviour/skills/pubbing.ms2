

# Pub patron behaviour.

# If I have a beer in my hand, drink it
rule pubbing-drink-beer-proposal
{@self pubbing}
{@self hand ?hand}
{?hand control [k drinking_glass]:?glass}
{?glass control [k beer]}
    -> /cont-interval 8 2
(begin_proposal {@self drink ?glass}).

# If I don't, order one
rule pubbing-order-beer-proposal
{@self pubbing}
{?bartender perform [k bartending] ?pub}
(in @self ?pub)
(none {@self hand.control [k drinking_glass]})
    ->
(begin_proposal {@self order [k beer] ?bartender}).

# If I am holding an empty glass in my hand, put it away
rule pubbing-put-away-empty-glass-proposal
{@self pubbing}
{@self hand ?hand}
{?hand control [k drinking_glass]:?glass}
{?glass control _}
(closest [k counter]|[k table]): ?surface
    ->
(begin_proposal {@self put ?glass ?surface}).


# -------------------------------------------------------------
# Ordering a beer
# -------------------------------------------------------------

# First, signal you want to talk to the bartender
# (and stay on your side of the counter)
rule pubbing-order-beer-talk-to-bartender
{@self pubbing}
{?bartender perform [k bartending] ?pub}
{@self order [k beer] ?bartender}
{?pub part [k bar_counter]:?bar_counter}
    ->
(maintain_goal {@self talk_to ?bartender})
(bb_private_maintain @self talk_cell_constraint '(des right_in_front_of ?bar_counter)).

# Wait for the bartender
rule pubbing-order-beer-wait-at-bar
{@self pubbing}
{@self order [k beer] ?bartender}: ?order
{?bartender perform [k bartending] ?pub}
{?pub part [k bar_counter]:?bar_counter}
(bb_public_read @self talk_cell): ?talk_cell
(overlaps ?talk_cell @self)
    ->
(bb_public_write @self wants_drink @true)
#(maintain_proposal {@self TURN_TO ?bar_counter})
(maintain_proposal {@self keep_looking_at_part ?bartender eyes}).


# When the bartender serves me a beer, take it
rule pubbing-order-beer-take-beer
{@self pubbing}
{@self order [k beer] ?bartender}: ?order
{?bartender perform [k bartending] ?pub}
(bb_public_read @self drinking_glass_cell): ?beer_cell
(env_cell_occupier [k drinking_glass] ?beer_cell): ?beer_glass
    ->
(set_outcome /succ {@self goal {@self talk_to ?bartender}})
(begin_proposal {@self take ?beer_glass}).


# Once I've ordered and taken the beer,
# I'm done being served and I release my slot to others.
# Also release the spawn cell the bartender claimed for this glass - the glass
# is now in our hand so the bar-top cell is free for the next patron's drink.
rule pubbing-order-beer-unclaim-spot-at-bar
{@self pubbing}
{?bartender perform [k bartending] ?pub}
{@self order [k beer] ?bartender}: ?order
{@self /succ take ?beer /causes ~?order}
(bb_public_read @self drinking_glass_cell): ?spawn_cell
    ->
(unclaim_env_cell ?spawn_cell)
(bb_public_clear @self drinking_glass_cell)
(bb_public_clear @self wants_drink)
(set_outcome ?order /succ).


