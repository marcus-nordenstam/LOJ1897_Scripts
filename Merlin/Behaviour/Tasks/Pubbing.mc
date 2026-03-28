
# Pub patron behaviour.

rule pubbing-order-beer-proposal
{@self pubbing}
(in @self [k building pub] /output-container): ?pub
(none {@self hand.control.control [k beer]})
    ->
(maintainProposal {@self order [k beer] ?pub}).


rule order-beer-claim-spot
{@self order [k beer] [k building pub]:?pub}
(none {[k receiver_station] actor_spot_holder @self})
(closestPart [k receiver_station] ?pub [{@o actor_spot_holder @nothing}]): ?station
    ->
(maintainProposal {@self CLAIM_TRANSACTION_STATION ?station}).


rule order-beer-go-to-station
{@self order [k beer] [k building pub]:?pub}
{?pub part [k transaction_zone]:?zone}
{?zone part [k transaction_station]:?station}
{?station actor_spot_holder @self}
(overlaps /not @self ?station 1)
    ->
(maintainProposal {@self go ?station}).


rule order-beer-wait-at-station
{@self order [k beer] [k building pub]:?pub}
{?pub part [k transaction_zone]:?zone}
{?zone part [k transaction_station]:?station}
{?station actor_spot_holder @self}
(overlaps @self ?station 1)
    ->
(maintainProposal {@self MIRROR ?station})
(maintainProposal {@self HALT}).
