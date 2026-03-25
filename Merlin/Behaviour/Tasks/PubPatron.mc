
# Pub patron behaviour.

# This rule simply maintains the {@self in pub-building} belief
# or {@self /not in pub-building}
rule pubbing-in-pub-belief
{@self pubbing}
(in @self [k building pub]) 
    ->
.


rule pubbing-order-beer-proposal
{@self pubbing}
{@self in [k building pub]:?pub}
(none {@self hand.control.control [k beer]})
    ->
(maintainProposal {@self order [k beer]}).


rule pubbing-order-beer-claim-spot
{@self pubbing}
{@self order [k beer]}
{@self in [k building pub]:?pub}
(none {[k receiver_station] actor_spot_holder @self})
(closestPart [k receiver_station] ?pub [{@o actor_spot_holder @nothing}]): ?station
    ->
(maintainProposal {@self CLAIM_TRANSACTION_STATION ?station}).


rule pub-patron-go-to-station
{@self pubbing}
{@self order [k beer]}
{@self in [k building pub]:?pub}
{?pub part [k transaction_zone]:?zone}
{?zone part [k transaction_station]:?station}
{?station actor_spot_holder @self}
(overlaps /not @self ?station 1)
    ->
(maintainProposal {@self go ?station}).


rule pub-patron-wait-at-station
{@self pubbing}
{@self order [k beer]}
{@self in [k building pub]:?pub}
{?pub part [k transaction_zone]:?zone}
{?zone part [k transaction_station]:?station}
{?station actor_spot_holder @self}
(overlaps @self ?station 1)
    ->
(maintainProposal {@self HALT}).
