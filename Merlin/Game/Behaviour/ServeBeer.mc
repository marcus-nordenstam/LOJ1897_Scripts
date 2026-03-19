
# serve_beer task: bartender serves a beer to a human

# Step 1: Find a beer_spawnpoint and go to it
rule serve_beer-go-to-spawnpoint
{@self serve_beer ?patron}
{?sp isa [k beer_spawnpoint]}
{?sp obb !@unknown}
    ->
(maintainProposal {@self keepInReachOf ?sp} /absUtil 1000)
(maintainProposal {@self keepFacing ?sp} /absUtil 1000).

# Step 2: Once at the spawnpoint, spawn a drinking glass
rule serve_beer-spawn-glass
{@self serve_beer ?patron}
{?sp isa [k beer_spawnpoint]}
{@self withinReachOf ?sp}
{@self facing ?sp}
{@self /not /ever SPAWN [k drinking_glass]}
    ->
(maintainProposal {@self SPAWN [k drinking_glass] ?sp}).

# Step 3: Once glass exists, spawn beer
rule serve_beer-spawn-beer
{@self serve_beer ?patron}
{?glass isa [k drinking_glass]}
{@self /not /ever SPAWN [k beer]}
    ->
(maintainProposal {@self SPAWN [k beer] ?glass}).

# Step 4: Pour beer into glass (only if beer is not yet controlled by anything)
rule serve_beer-pour
{@self serve_beer ?patron}
{?glass isa [k drinking_glass]}
{?beer isa [k beer]}
(none {@something control ?beer})
    ->
(maintainProposal {@self POUR ?beer ?glass}).

# Step 5: Outcome (beer is now controlled by the glass)
rule serve_beer-outcome
{@self /ever serve_beer ?patron /noOut}: ?task
{?beer isa [k beer]}
{?glass control ?beer}
    ->
(setOutcome ?task /succ).
