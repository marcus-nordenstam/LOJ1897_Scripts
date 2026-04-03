
# Pay attention to what you're trying to be near & facing

rule keep_near_and_facing-attention
{@self keep_near_and_facing ?thing}
    ->
(maintainAttention ?thing).

# You must be near it

rule keep_near_and_facing-withinReachOf-belief
{@self keep_near_and_facing ?thing}
(isWithinReachOf ?thing 0.8 /cont) = ?prob # get 20% closer to the target before stopping
    ->
(maintainBelief {@self withinReachOf ?thing /p ?prob}).

rule keep_near_and_facing-withinReachOf-go-proposal
{@self keep_near_and_facing ?thing}
{@self /not withinReachOf ?thing}
    ->
(maintainProposal {@self go ?thing}).

# You must face it
# Bear in mind that facing is NOT exclusive

rule keep_near_and_facing-facing-belief
{@self keep_near_and_facing ?thing}
(isFacing ?thing 0.9 /cont) = ?prob
    ->
(maintainBelief {@self facing ?thing /p ?prob}).

rule keep_near_and_facing-TURN_TO-proposal
{@self keep_near_and_facing ?thing}
{@self /not facing ?thing}
    ->
(maintainProposal {@self TURN_TO ?thing}).
