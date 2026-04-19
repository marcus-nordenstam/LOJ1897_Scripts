

rule go-home-when-sleepy
{@self home ?home}
{@self alertness sleepy}
(in @self ?home /not)
    ->
(maintainProposal {@self go_entity ?home}).