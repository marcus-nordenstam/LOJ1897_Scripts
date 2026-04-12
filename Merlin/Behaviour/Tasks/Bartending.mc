


# if you have nothing to do, hang in back in the bar
rule bartending-idle-hang-back
{@self perform [k bartending] ?pub}
{?pub part [k bar_back]:?bar_back}
(none {@self serve_customer})
(isWithinReachOf /not /center ?bar_back 0.5) # get 50% closer to the target before stopping
    ->
(maintainProposal {@self go ?bar_back}).

rule bartending-idle-face-bar
{@self perform [k bartending] ?pub}
{?pub part [k bar_back]:?bar_back}
(none {@self serve_customer})
(isWithinReachOf /center ?bar_back)
    ->
(maintainProposal /cont {@self MIRROR ?bar_back}).


# TODO: Enable when env-grid API is tested in Player
#
# # identify customer and serve them
# rule bartending-serve-customer-proposal
# {@self perform [k bartending] ?pub}
# {?pub part [k bar_counter]:?bar_counter}
# (none {@self serve_customer})
# (env_cell_occupier [k human] /adjacent_to ?bar_counter /least-recently-checked): ?patron
# (none {[k drinking_glass] for ?patron})
# (lockRule) # Deal with one patron at a time
#     ->
# (beginProposal {@self serve_customer ?patron} /absUtil 1000).
#
#
# # find out what drink customer wants
# rule bartending-serve-customer-know-what-to-serve-goal
# {@self perform [k bartending] ?pub}
# {@self serve_customer ?patron}
#     ->
# (maintainGoal {@self know '(any {?patron order ? @self}).target}).
#
#
# # spawn in the glass
# rule bartending-serve-customer-SPAWN-glass-proposal
# {@self perform [k bartending] ?pub}
# {@self serve_customer ?patron}: ?serve
# {?patron order ?drink @self}
# {?pub part [k bar_counter]:?bar_counter}
# (env_cell /dim [k drinking_glass] /available /on-top-of ?bar_counter /near ?patron): ?cell
#     ->
# (bb_write ?patron served_beer_cell ?cell)
# (beginProposal {@self SPAWN [[k drinking_glass] ?cell]}).
#
#
# # pour the beer into the glass, which both spawns the beer and makes the glass control the beer.
# rule bartending-serve-customer-POUR-beer-proposal
# {@self perform [k bartending] ?pub}
# {@self serve_customer ?patron}: ?serve
# {?patron order ?drink @self}
# (bb_read /cont ?patron served_beer_cell ?beer_cell)
# (env_cell_occupier [k drinking_glass] ?beer_cell): ?beer_glass
#     ->
# (beginProposal {@self POUR [k beer] ?beer_glass})
# (setOutcome /succ ?serve).
