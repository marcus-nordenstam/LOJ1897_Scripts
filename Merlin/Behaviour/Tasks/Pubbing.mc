
# Pub patron behaviour.
rule pubbing-order-beer-proposal
{@self pubbing}
{?bartender perform [k bartending] ?pub}
(in @self ?pub)
(none {@self hand.control.control [k beer]})
    ->
(maintainProposal {@self order [k beer] ?bartender}).


rule pubbing-order-beer-claim-spot
{@self pubbing}
{@self order [k beer] ?bartender}
{?bartender perform [k bartending] ?pub}
(none {[k receiver_station] actor_spot_holder @self})
(closestPart [k receiver_station] ?pub [{@o actor_spot_holder @nothing}]): ?station
    ->
(maintainProposal {@self CLAIM_TRANSACTION_STATION ?station}).


rule pubbing-order-beer-go-to-station
{@self pubbing}
{@self order [k beer] ?bartender}
{?bartender perform [k bartending] ?pub}
{?pub part [k transaction_zone]:?zone}
{?zone part [k transaction_station]:?station}
{?station actor_spot_holder @self}
(overlaps /not @self ?station 1)
    ->
(maintainProposal {@self go ?station}).


rule pubbing-order-beer-wait-at-station
{@self pubbing}
{@self order [k beer] ?bartender}
{?bartender perform [k bartending] ?pub}
{?pub part [k transaction_zone]:?zone}
{?zone part [k transaction_station]:?station}
{?station actor_spot_holder @self}
(overlaps @self ?station 1)
    ->
(maintainProposal {@self MIRROR ?station})
(maintainProposal {@self HALT}).


rule pubbing-order-beer-take-beer
{@self pubbing}
{@self order [k beer] ?bartender}
{?bartender perform [k bartending] ?pub}
{?pub part [k transaction_zone]:?zone}
{?zone part ?station}
{?station actor_spot_holder @self}
{?station staging_spot_occupier @something:?beer}
    ->
(beginProposal {@self take ?beer}).
