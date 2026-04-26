
rule seek-answers-ask-unknowns
{@self seek_answers ?knowledge_list}: ?seek_answers
(unknowns ?knowledge_list): ?unknowns # get a list of knowledge that I still don't know
    ->
#(print [SEEKANSWERS @self must learn (count ?unknowns) unknowns])
#(print (nl ?unknowns))
(if (empty ?unknowns)
    [ (setOutcome ?seek_answers /succ)   (print [TASK DONE (nl ?seek_answers)]) ] 
# else
    (maintainGoals ?unknowns {@self know @litem} (rel_util (mul @lindex 0.1)))).