
rule 
{@self seekAnswers ?knowledge_list}: ?seekAnswers
(unknowns ?knowledge_list): ?unknowns # get a list of knowledge that I still don't know
    ->
#(print [SEEKANSWERS @self must learn (count ?unknowns) unknowns])
#(print (nl ?unknowns))
(if (empty ?unknowns)
    [ (setOutcome ?seekAnswers /succ)   (print [TASK DONE (nl ?seekAnswers)]) ] 
# else
    (maintainGoals ?unknowns {@self know @litem} /relUtil (mul @lindex 0.1))).