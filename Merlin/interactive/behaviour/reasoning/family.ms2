

rule learn-birth-family
{@self mother ?mother}
{@self father ?father}
    ->
(o [k family] {@self family @o}): ?family
(begin_belief {?mother spouse ?father})
(begin_belief {?father spouse ?mother})
(begin_belief {?mother family ?family})
(begin_belief {?father family ?family})
#(print [@self has family members (any {@self familyMembers}).target])
(fire_and_forget).


# We need to either make family exclusive, or
#   end {.. family @unknown}
#   maybe separate our immediate family from the spouse's side of the family...?

rule learn-family-via-spouse
{@self spouse @something:?spouse}
    ->
(o [k family] {@self family @o}): ?family
(begin_belief {?spouse family ?family})
#(print [@self has family members (any {@self familyMembers}).target])
(fire_and_forget).

rule learn-family-via-child
{@self child ?child}
    ->
(o [k family] {@self family @o}): ?family
(begin_belief {?child family ?family})
#(print [@self has family members (any {@self familyMembers}).target])
(fire_and_forget).

rule learn-family-via-sister
{@self sister ?sister}
    ->
(o [k family] {@self family @o}): ?family
(begin_belief {?sister family ?family})
#(print [@self has family members (any {@self familyMembers}).target])
(fire_and_forget).

rule learn-family-via-brother
{@self brother ?brother}
    ->
(o [k family] {@self family @o}): ?family
(begin_belief {?brother family ?family})
#(print [@self has family members (any {@self familyMembers}).target])
(fire_and_forget).

