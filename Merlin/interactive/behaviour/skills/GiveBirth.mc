
rule give-birth-propose
{@self pregnant_when !_:?when}
(gt (timeSince /weeks ?when) 39)
    ->
(maintain_proposal {@self GIVE_BIRTH}).

# If you're pregnant you must decide on a name for the baby
#rule
#{@self pregnant_when !_:?when}
