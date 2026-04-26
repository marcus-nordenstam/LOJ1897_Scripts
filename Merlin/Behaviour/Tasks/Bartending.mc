

# if you have nothing to do, hang in back in the bar
rule bartending-idle-face-bar
{@self perform [k bartending] ?pub}
{?pub part [k bar_counter]:?bar_counter}
(none {@self serve_customer})
    ->
(maintainProposal {@self TURN_TO ?bar_counter}).


# identify customer and serve them
rule bartending-serve-customer-proposal
{@self perform [k bartending] ?pub}
{?pub part [k bar_counter]:?bar_counter}
(none {@self serve_customer}) # no code after this should be reached WHILE serving a customer
(env_cell_occupier [k human] (in_front_of_des ?bar_counter) 
    '(and (bb_public_read @o wants_drink) 
          (bb_public_none @o drinking_glass_cell))): ?patron
(claim_env_cell (behind_des ?bar_counter) (near_des ?patron)): ?talk_cell
(lockRule) # Deal with one patron at a time
    ->
(beginProposal {@self serve_customer ?patron} (abs_util 1000))
(bb_public_write @self talk_cell ?talk_cell).


# find out what drink customer wants
rule bartending-serve-customer-know-what-to-serve-goal
{@self perform [k bartending] ?pub}
{@self serve_customer ?patron}
{?pub part [k bar_counter]:?bar_counter}
    ->
(maintainGoal {@self know '(any {?patron order ? @self}).target}).


# spawn in the glass
rule bartending-serve-customer-SPAWN-glass-proposal
{@self perform [k bartending] ?pub}
{@self serve_customer ?patron}: ?serve
{?patron order ?drink @self}
{?pub part [k bar_counter]:?bar_counter}
(bb_public_none ?patron drinking_glass_cell)
(claim_env_cell (env_grid_level [k drinking_glass]) (on_top_of_des ?bar_counter) (near_des ?patron) /debug): ?cell
    ->
(bb_public_write ?patron drinking_glass_cell ?cell)
(beginProposal {@self SPAWN [[k drinking_glass] ?cell]}).


# pour the beer into the glass, which both spawns the beer and makes the glass control the beer.
rule bartending-serve-customer-POUR-beer-proposal
{@self perform [k bartending] ?pub}
{@self serve_customer ?patron}: ?serve
{?patron order ?drink @self}
(bb_public_read ?patron drinking_glass_cell): ?beer_cell
(env_cell_occupier [k drinking_glass] ?beer_cell): ?beer_glass
    ->
(beginProposal {@self POUR [k beer] ?beer_glass})
(bb_public_read @self talk_cell): ?talk_cell
(unclaim_env_cell ?talk_cell)
(bb_public_clear @self talk_cell)
(setOutcome /succ ?serve).
