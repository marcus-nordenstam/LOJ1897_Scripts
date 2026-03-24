
# Pub patron behaviour.

rule pub-patron-claim-spot
{@self pubbing}
(in @self [k building pub]): ?pub
(none {[k receiver_station] actor_spot_holder @self})
(closestPart [k receiver_station] ?pub [{@o actor_spot_holder @nothing}]): ?station
    ->
(maintainProposal {@self CLAIM_TRANSACTION_STATION ?station}).

rule pub-patron-go-station
{@self pubbing}
{@self in ?pub}
{?pub part [k transaction_zone]:?zone}
{?zone receiver_station ?station}
{?station actor_spot_holder @self}
(overlaps /not @self ?station 1)
    ->
(maintainProposal {@self go ?station}).
