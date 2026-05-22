# TODO:
#   Generate a match-score based on
#       Attraction 
#       Suitability 
#       (For men only) Number of times asked with uncertain answer
#   Then have that be used in selecting the current marriage-prospect


# I am single (no ongoing spouse or fiancee) and want to size up an
# age-appropriate, opposite-gender, non-kin person whose marital status I
# have not yet worked out - propose to infer it from their rings.
rule infer-marital-state-of-others
{@self gender ?gender}
{[k human]:?person gender !?gender}
{?person age_group >0}
{@self family ?myFamily}
{?person family !?myFamily}
(none {@self spouse @something})
(none {@self fiancee @something})
(none {?person spouse ?})
(none {?person fiancee ?})
    ->
(maintain_proposal {@self infer {?person spouse}}).


# An age-appropriate, opposite-gender, living, non-kin person who is single
# (no ongoing spouse or fiancee, on either side) is a marriage prospect:
# seed their marriage_desirability. Eligibility is derived here, not stored.
rule seed-marriage-desirability
{@self gender ?gender}
{!@self:?person gender !?gender}
{?person condition alive}
{@self family ?myFamily}
{?person family !?myFamily}
(none {@self spouse @something})
(none {@self fiancee @something})
(none {?person spouse @something})
(none {?person fiancee @something})
    ->
(if (none {?person marriage_desirability})
    (begin_belief {?person marriage_desirability (sub 1000 (id ?person))})).

rule marry-desirability-decrease-longtime-no-see
{@self goal {@self marry ?prospect}}
{?prospect marriage_desirability ?desirability}
(time_since_observed ?prospect /years): ?timeSince
(ge ?timeSince 1)
    ->
(sub ?desirability ?timeSince): ?newDesirability
(begin_belief {?prospect marriage_desirability ?newDesirability}).


rule goal-marry
{? marriage_desirability ?}
(none {@self spouse @something})
(highest /target {? marriage_desirability ?}): ?desirabilityEvent
(lookup ?desirabilityEvent).subject: ?prospect
(lookup ?desirabilityEvent).target: ?desirability
    ->
#(every {? marriage_desirability ?}): ?every
#(print ?every)
#(print [@self chooses ?prospect with ?desirability desirability])
#(log "pattern" on)
(maintain_goal {@self marry ?prospect})
#(log "pattern" off)
(check (gt ?desirability 0))
(check (eq 1 (count (every {@self goal {@self marry ?}})))).
