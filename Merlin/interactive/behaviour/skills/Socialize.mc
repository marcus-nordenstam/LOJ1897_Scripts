
# Social activities
#   AgeGroup 2+
#   Attend theatre (to provide a place where they can get to know others)
rule socialize-go-theatre
{@self alertness alert}
{@self spouse _}
#{@self age_group >1}
{[k building theatre]:?theatre obb ?obb}
(in @self ?theatre /not)
#(none {@self child})
    ->
(maintain_proposal {@self go_entity ?theatre}).



/*
rule get_acquainted_with
{@self age_group >1}
{@self gender ?gender}
{?person gender !?gender}
{?person age_group >1}
{@self family ?myFamily}
{?person family !?myFamily}
(lockRule) # only one firing of this rule at a time / mind
(real ?person)
(none {@self /succ get_acquainted_with ?person}) # we don't know this person
    ->
(maintain_proposal {@self get_acquainted_with ?person}).

*/