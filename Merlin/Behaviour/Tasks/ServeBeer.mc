
# serve_beer task: bartender serves a beer to a human
/*
rule bartender-perform-job
{@self job [k bartender]:?job}
    ->
(maintainProposal {@self perform ?job}).

rule bartender-serve_beer
{@self perform [k bartender]}
# Right now, we just serve beer to ANY human we see
# later we will require that the patron demands a beer 
# before serving
{!@self:?patron isa [k human]}
    ->
(maintainProposal {@self serve_beer ?patron}).


# Spawn a beer at the spawnpoint
rule serve_beer-SPAWN-proposal
{@self serve_beer ?patron}
{?sp isa [k beer_spawnpoint]}
    ->
(maintainProposal {@self SPAWN [[k drinking_glass] ?sp] [{@o for ?patron}]})
(maintainProposal {@self SPAWN [[k beer] ?sp] [{@o for ?patron}]}).


# Pour uncontrolled beer into glass
rule serve_beer-POUR-proposal
{@self serve_beer ?patron}
{[k drinking_glass]:?glass for ?patron}
{[k beer]:?beer for ?patron}
    ->
(maintainProposal {@self POUR ?beer ?glass}).


rule serve_beer-outcome
{@self serve_beer ?patron}: ?serve_beer
{[k drinking_glass]:?glass for ?patron}: ?glass_for_patron
{[k beer]:?beer for ?patron}: ?beer_for_patron
{@self /ever POUR ?beer ?glass /out?}: ?POUR
    ->
(setOutcome ?serve_beer /from ?POUR)
(forget ?glass_for_patron)
(forget ?beer_for_patron).
*/