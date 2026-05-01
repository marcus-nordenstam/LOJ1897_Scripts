
# if you have nothing to do, hang in back in the bar
rule bartending-idle-face-bar
{@self perform [k bartending] ?pub}
{?pub part [k bar_counter]:?bar_counter}
(none {@self serve_customer})
    ->
(maintain_proposal {@self TURN_TO ?bar_counter}).


# identify customer and serve them
rule bartending-serve-customer-proposal
{@self perform [k bartending] ?pub}
{?pub part [k bar_counter]:?bar_counter}
# deal with one patron at a time:
(none {@self proposal {@self serve_customer}}) # no code after this should be reached WHILE serving a customer
(env_cell_occupier [k human] 
                   (des right_in_front_of ?bar_counter) 
                   '(and (bb_public_read @o wants_drink) 
                         (bb_public_none @o drinking_glass_cell))): ?patron
(bb_public_read ?patron talk_cell): ?patron_talk_cell
    ->
(begin_proposal {@self serve_customer ?patron} (des abs_util 1000))
(bb_private_write @self talk_cell_constraint '[(des behind ?bar_counter)
                                               (des across_from ?patron_talk_cell)]).


# find out what drink customer wants
rule bartending-serve-customer-know-what-to-serve-goal
{@self perform [k bartending] ?pub}
{@self serve_customer ?patron}
{?pub part [k bar_counter]:?bar_counter}
    ->
(maintain_goal {@self know '(any {?patron order ? @self}).target}).

# spawn in the glass
rule bartending-serve-customer-SPAWN-glass-proposal
{@self perform [k bartending] ?pub}
{@self serve_customer ?patron}: ?serve
{?patron order ?drink_kind @self}
{?pub part [k bar_counter]:?bar_counter}
(bb_public_none ?patron drinking_glass_cell)
(claim_env_cell (env_cell_size [k drinking_glass]) 
                (des on_top_of ?bar_counter) 
                (des near ?patron) /debug): ?cell
    ->
(bb_public_write ?patron drinking_glass_cell ?cell)
(begin_proposal {@self SPAWN [[k drinking_glass] ?cell]}).


# pour the beer into the glass, which both spawns the beer and makes the glass control the beer.
rule bartending-serve-customer-POUR-beer-proposal
{@self perform [k bartending] ?pub}
{@self serve_customer ?patron}: ?serve
{?patron order ?drink_kind @self}
(bb_public_read ?patron drinking_glass_cell): ?beer_cell
(env_cell_occupier [k drinking_glass] ?beer_cell): ?beer_glass
    ->
(begin_proposal {@self POUR ?drink_kind ?beer_glass})
(unclaim_env_cell ?beer_cell)
(bb_private_clear @self talk_cell_constraint).


rule bartending-serve-customer-outcome
{@self perform [k bartending] ?pub}
{@self serve_customer ?patron}: ?serve
{?patron order ?drink_kind @self}: ?order
{@self /succ POUR ?drink_kind ? /causes ~?serve}
    ->
(endBelief ?order)
(set_outcome /succ ?serve).