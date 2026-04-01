


# if you have nothing to do, hang in back in the bar
rule bartending-idle-hang-back
{@self perform [k bartending] ?pub}
{?pub part [k bar_work_aisle]:?work_aisle}
(none {@self serve_customer})
(isWithinReachOf /not /center ?work_aisle 0.5) # get 50% closer to the target before stopping
    ->
(maintainProposal {@self go ?work_aisle}).

rule bartending-idle-face-bar
{@self perform [k bartending] ?pub}
{?pub part [k bar_work_aisle]:?work_aisle}
(none {@self serve_customer})
(isWithinReachOf /center ?work_aisle)
    ->
(maintainProposal /cont {@self MIRROR ?work_aisle}).

rule bartending-idle-look-at-customers
{@self perform [k bartending] ?pub}
(none {@self serve_customer})
(observed /cont-interval 4 1 /leastRecent (in /every [k human] ?pub)): ?least_recently_observed_customer
    ->
(maintainProposal /cont-interval 4 1 {@self LOOK_AT ?least_recently_observed_customer}).


# identify customer and serve them
rule bartending-serve-customer-proposal
{@self perform [k bartending] ?pub}
{?pub part [k transaction_zone]:?zone}
{?zone part [k transaction_station]:?station}
{?station actor_spot_holder @something:?patron}
{?station staging_spot_occupier @nothing} # nothing is currently served for this patron
(overlaps ?patron ?station 1)
(lockRule) # Deal with one patron at a time
    ->
(beginProposal {@self serve_customer ?patron} /absUtil 1000).


# find out what drink customer wants
rule bartending-serve-customer-know-what-to-serve-goal
{@self perform [k bartending] ?pub}
{@self serve_customer ?patron}
    ->
(maintainGoal {@self know '(any {?patron order ? @self}).target}).


# spawn in the drink
rule bartending-serve-customer-SPAWN-drink-proposal
{@self perform [k bartending] ?pub}
{@self serve_customer ?patron}: ?serve
{?pub part [k transaction_zone]:?zone}
{?zone part [k provider_staging_spot]:?sp}
{?zone part ?station}
{?station actor_spot_holder ?patron}
{?patron order ?drink @self}
    ->
(beginProposal {@self SPAWN [[k drinking_glass] ?sp] [{@o for ?patron}]})
(beginProposal {@self SPAWN [[k beer] ?sp] [{@o for ?patron}]}).


# Make the glass control the beer, and set the full glass as the 
# provider's occupier so that the patron recognizes which beer-glass is theirs
rule bartending-serve-customer-POUR-drink-proposal
{@self perform [k bartending] ?pub}
{@self serve_customer ?patron}: ?serve
{?station actor_spot_holder ?patron}
{[k drinking_glass]:?glass for ?patron}
{[k beer]:?beer for ?patron}
    ->
(beginProposal {@self POUR ?beer ?glass})
(beginProposal {@self SET_PROVIDER_OCCUPIER_SLOT ?glass ?station})
(setOutcome /succ ?serve).