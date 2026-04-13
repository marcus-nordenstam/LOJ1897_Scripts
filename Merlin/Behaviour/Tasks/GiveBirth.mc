
rule 
{@self pregnant_when !@nothing:?when}
(gt (timeSince /cont /weeks ?when) 39)
    ->
(maintainProposal {@self GIVE_BIRTH}).

# If you're pregnant you must decide on a name for the baby
#rule
#{@self pregnant_when !@nothing:?when}
