

# we are all npcs
#{@we game_role nonplayer}

# we are all married
#{@we spouse @something}

# we are married to each other
#{@we spouse @weOther}

# we are related
#{@we xfamily ~@weOther}

# we are not related
#{@we xfamily ^@weOther}

/*
# grandparents

rule 
{@self [mother|father] ?parent}
{?parent mother ?grand_mother}
    ->
(e {@self grand_mother ?grand_mother}).


rule 
{@self [mother|father] ?parent}
{?parent father ?grand_father}
    ->
(e {@self grand_father ?grand_father})


rule 
{@self [grand_mother|grand_father] ?grandParent}
    ->
(e {@self grand_parents ~?grandParent}).


# great grandparents

rule 
{@self [grand_mother|grand_father] ?grandParent}
{?grandParent mother ?great_grand_mother}
    ->
(e {@self great_grand_mother ?great_grand_mother})


rule 
{@self [grand_mother|grand_father] ?grandParent}
{?grandParent father ?great_grand_father}
    ->
(e {@self great_grand_father ?great_grand_father})


rule 
{@self [great_grand_mother|great_grand_father] ?greatGrandParent}
    ->
(e {@self great_grand_parents ~?greatGrandParent}).



# uncles

rule 
{@self [mother|father] ?parent}
{?parent brother ?uncle}
    ->
(e {@self uncle ?uncle}).


rule 
{@self [grand_mother|grand_father] ?grand_father}
{?grand_father brother ?great_uncle}
    ->
(e {@self great_uncle ?great_uncle})



# aunts

rule 
{@self [mother|father] ?parent}
{?parent sister ?aunt}
    ->
(e {@self aunt ?aunt}).

rule 
{@self [grand_mother|grand_father] ?grand_father}
{?grand_father sister ?great_aunt}
    ->
(e {@self great_aunt ?great_aunt})



# updating cousins

rule 
{@self [uncle|aunt] ?uncleOrAunt}
{?uncleOrAunt child ?cousin}
    ->
(e {@self cousin ?cousin}).


# Family members
rule 
{@self [father|mother|sister|brother|spouse|children] ?familyMember}
    ->
(e {@self family ~?familyMember}).


# Extended family members

{@self family ?family}
    ->
(e {@self xfamily ~?family}).

{@self [cousins|nephews|nieces|uncle|aunt|great_aunt|great_uncle|grand_parents|great_grand_parents|grand_children] ?xfamilyMember}
    ->
(e {@self xfamily ~?xfamilyMember}).

*/