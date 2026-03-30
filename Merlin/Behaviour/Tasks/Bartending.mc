

# identify customer and serve them
rule serve-customer-proposal
{@self perform [k bartending] ?pub}
{?pub part [k transaction_zone]:?zone}
{?zone part [k transaction_station]:?station}
{?station actor_spot_holder @something:?patron}
(overlaps ?patron ?station 1)
(lockRule) # Deal with one patron at a time
    ->
(beginProposal {@self serve_customer ?patron}).


# find out what drink customer wants
rule serve-customer-know-what-to-serve-goal
{@self perform [k bartending] ?pub}
{@self serve_customer ?patron}
    ->
(maintainGoal {@self know '(any {?patron order ? @self}).target}).


# spawn in the drink
rule serve-customer-SPAWN-drink-proposal
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
rule serve-customer-POUR-drink-proposal
{@self perform [k bartending] ?pub}
{@self serve_customer ?patron}
{?station actor_spot_holder ?patron}
{[k drinking_glass]:?glass for ?patron}
{[k beer]:?beer for ?patron}
    ->
(maintainProposal {@self POUR ?beer ?glass})
(maintainProposal {@self SET_PROVIDER_OCCUPIER_SLOT ?glass ?station}).
