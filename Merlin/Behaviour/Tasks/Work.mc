

rule work-go-to-workplace-proposal
{@self perform ?job}
{?job at ?org}
{?org workplace ?workplace}
(in /not @self ?workplace)
    ->
(maintainProposal {@self go_entity ?workplace}).

