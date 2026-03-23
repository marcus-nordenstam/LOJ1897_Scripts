
# Pub patron behaviour.

rule pub-patron-claim-spot
{@self pubbing}
(in @self [k building pub]): ?pub
(none {[k receiver_station] actor_spot_holder @self})
(closestPart [k transaction_zone] ?pub [{@o receiver_station.actor_spot_holder @nothing}]): ?zone
    ->
(maintainProposal {@self CLAIM_TRANSACTION_STATION ?zone receiver_station}).

rule pub-patron-go-station
{@self pubbing}
{@self in ?pub}
{?pub part [k transaction_zone]:?zone}
{?zone receiver_station ?station}
{?station actor_spot_holder @self}
{?station actor_spot_occupier @nothing}
    ->
(maintainProposal {@self go ?station}).
