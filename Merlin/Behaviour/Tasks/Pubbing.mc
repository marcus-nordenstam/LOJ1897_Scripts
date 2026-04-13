

# Pub patron behaviour.
rule pubbing-order-beer-proposal
{@self pubbing}
{?bartender perform [k bartending] ?pub}
(in @self ?pub)
(none {@self hand.control.control [k beer]})
    ->
(maintainProposal {@self order [k beer] ?bartender}).



rule pubbing-order-beer-claim-spot-at-bar
{@self pubbing}
{?bartender perform [k bartending] ?pub}
{@self order [k beer] ?bartender}
{?pub part [k bar_counter]:?bar_counter}
(bb_none @self open_bar_slot)
(claim_env_cell /in_front ?bar_counter): ?claimed_cell
    ->
(bb_write @self open_bar_slot ?claimed_cell).


rule pubbing-order-beer-go-to-bar
{@self pubbing}
{@self order [k beer] ?bartender}
(bb_read @self open_bar_slot): ?claimed_cell
(overlaps /not ?claimed_cell @self 0.8)
    ->
(maintainProposal {@self go_env_cell ?claimed_cell}).


rule pubbing-order-beer-wait-at-bar
{@self pubbing}
{@self order [k beer] ?bartender}
{?bartender perform [k bartending] ?pub}
{?bartender eyes ?bartender_eyes}
{?pub part [k bar_counter]:?bar_counter}
(bb_read @self open_bar_slot): ?claimed_cell
(overlaps ?claimed_cell @self 0.8)
    ->
(maintainProposal {@self TURN_TO ?bar_counter})
(maintainProposal {@self LOOK_AT ?bartender_eyes}).


/*
rule pubbing-order-beer-take-beer
{@self pubbing}
{@self order [k beer] ?bartender}: ?order
{?bartender perform [k bartending] ?pub}
(bb_read /cont @self served_beer_cell): ?beer_cell
(env_cell_occupier [k drinking_glass] ?beer_cell): ?beer_glass
    ->
(beginProposal {@self take ?beer_glass})
(bb_clear @self served_beer_cell).


rule pubbing-order-beer-unclaim-spot-at-bar
{@self pubbing}
{?bartender perform [k bartending] ?pub}
{@self /past order [k beer] ?bartender}: ?order
{@self /succ take ?beer /causes ~?order}
{?pub part [k bar_counter]:?bar}
{@self open_bar_slot ?claimed_cell}: ?open_bar_slot
    ->
(unclaim_env_cell ?claimed_cell)
(endBelief ?open_bar_slot).


rule pubbing-drink-beer-proposal
{@self pubbing}
{@self hand ?hand}
{?hand control [k drinking_glass]:?glass}
{?glass control [k beer]}
    ->
(beginProposal /cont-interval 8 2 {@self drink ?glass}).

*/