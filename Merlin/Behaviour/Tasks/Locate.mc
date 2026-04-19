

# Later on we can add smarts, but for now, locating just means exploring the whole world in hopes of seeing it

rule locate-explore-world-proposal
{@self locate ?something}
    ->
(maintainAttention ?something)
(maintainProposal {@self explore world}).
