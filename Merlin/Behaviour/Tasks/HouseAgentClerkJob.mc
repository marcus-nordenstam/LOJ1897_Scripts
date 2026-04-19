
rule house-agent-clerk-process-title-deed-for-buyer
{@self perform [k clerk]:?job}: ?working
{?job at [k house_agency]:?org}
{?buyer goal ?otask}
{?otask task {?buyer buy [k building]:?bldg}}: ?buyerWantsToBuy
(real ?bldg)
    ->
# We have to explicitly include ?buyerWantsToBuy as a cause, because it is NOT a self-act
(maintainProposal {@self process_title_deed ?buyer ?bldg /causes ?buyerWantsToBuy}).

rule house-agent-clerk-ask-buyer-name
{@self process_title_deed ?buyer ?bldg}
(none {?buyer name ?})
    ->
(maintainGoal {@self know '(any {?buyer name}).target} /relUtil 1).


rule house-agent-clerk-write-title-deed
{@self process_title_deed ?buyer ?bldg}
{?bldg isa [k building]:?bldgKind}
{?buyer name ?buyerName}
{?bldg name ?address}
    ->
(msg {(o ?bldgKind ?address) owner (o {@o name ?buyerName})}): ?writings
(o /invent /hyp [k title_deed] {@o writings ?writings}): ?hypTitleDeed
(maintainProposal {@self write ?hypTitleDeed}).


# Give the doc to buyer
rule house-agent-clerk-give-title-deed-to-buyer
{@self process_title_deed ?buyer ?bldg}: ?process_title_deed
{@self /succ write [k title_deed]:?doc /causes ~?process_title_deed}
{?buyer hand ?hand}
(real ?doc)
(none {?hand /ever control ?doc})
    ->
# Once give succeeds, then (endBelief  buyer-goal-to-buy...)
(maintainProposal {@self give ?doc ?buyer}).


# If someone wants to buy a property,
# and I've done my part (created a title-deed and given it to them)
# then 
