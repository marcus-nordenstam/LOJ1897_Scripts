
rule die-of-old-age-propose
{@self condition alive}
{@self age >60}
    ->
(maintainProposal {@self DIE}).

