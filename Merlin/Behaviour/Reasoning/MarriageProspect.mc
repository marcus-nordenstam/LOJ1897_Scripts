# TODO:
#   Generate a match-score based on
#       Attraction 
#       Suitability 
#       (For men only) Number of times asked with uncertain answer
#   Then have that be used in selecting the current marriage-prospect


rule inferMaritalState
{@self marital_state single}
{@self gender ?gender}
{[k human]:?person gender !?gender}
{?person age_group >0}
{?person marital_state @unknown}
{@self family ?myFamily}
{?person family !?myFamily}
    ->
#(maintainGoal {@self know '(any {?person marital_state}).target}).
(maintainProposal {@self infer {?person marital_state}}).


rule eligible_for_marriage
{@self marital_state single}
{@self gender ?gender}
{!@self:?person gender !?gender}
{?person condition alive}
{?person marital_state single}
{@self family ?myFamily}
{?person family !?myFamily}
    ->
(maintainBelief {?person eligible_for_marriage})
(if (none {?person marriage_desirability})
    (beginBelief {?person marriage_desirability (sub 1000 (id ?person))}))
(print [@self believes ?person is eligible for marriage])
(print [@self thinks ?person "has marriage-desirability" (any {?person marriage_desirability}).target]).


rule marry-desirability-decrease-longtimeNoSee
{@self goal {@self marry ?prospect}}
{?prospect marriage_desirability ?desirability}
(timeSinceObserved ?prospect /years /cont): ?timeSince
(ge ?timeSince 1)
    ->
(sub ?desirability ?timeSince): ?newDesirability
(beginBelief {?prospect marriage_desirability ?newDesirability}).


rule goal-marry
{@self marital_state !married}
(highest /target {? marriage_desirability ?}): ?desirabilityEvent
(lookup ?desirabilityEvent).subject: ?prospect
(lookup ?desirabilityEvent).target: ?desirability
    ->
#(every {? marriage_desirability ?}): ?every
#(print ?every)
(print [@self chooses ?prospect with ?desirability desirability])
#(log "pattern" on)
(maintainGoal {@self marry ?prospect})
#(log "pattern" off)
(check (gt ?desirability 0))
(check (eq 1 (count (every {@self goal {@self marry ?}})))).
