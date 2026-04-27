
/*
rule 
{@self report ?infos ?audience}: ?reportInfos
(unknowns {@self /succ TELL @litem ?audience /causes ~?reportInfos} ?infos): ?unreportedInfos
    ->
(if (empty ?unreportedInfos)
    (set_outcome ?reportInfos /succ)
# else
    (maintain_goal {@self TELL @litem ?audience} ?unreportedInfos (des rel_util (mul @lindex 0.1)))).
*/