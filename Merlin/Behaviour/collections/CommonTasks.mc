
rule import-nourishment-tasks
    ->
(import "Drink").

rule import-movement-tasks
    ->
(import "Go")
(import "keep_near_and_facing")
(import "MaintainLookingAt")
(import "Explore")
(import "Locate")
(import "GoHome").


rule import-resource-tasks
    ->
(import "Give")
(import "Receive")
(import "Get")
(import "Take")
(import "Put")
(import "BuyBuilding").


rule import-learning-tasks
    ->
(import "IdentifyPerson")
(import "SeekAnswers")
(import "GetAcquaintedWith")
(import "find_out")
(import "Read")
(import "PerceiveAttr").


rule import-social-tasks
    ->
(import "Talk")
(import "AnswerQuestion")
(import "HearAnswer")
(import "HearTell")
(import "WriteDoc")
(import "Introduce")
(import "Socialize")
(import "Pubbing").


rule import-stack-tasks
    ->
(import "StackBrowse")
(import "StackGet")
(import "StackPut")
(import "StackRead")
(import "MakeDoneStack").


rule import-family-tasks
    ->
(import "Engagement")
(import "Marriage")
(import "Parenting").


rule import-professional-tasks
    ->
(import "Work")
(import "FoundOrg")
(import "HouseAgentClerkJob")
(import "Bartending").

rule import-emotional-tasks
    ->
(import "Grieve").

rule import-weather-tasks
    ->
(import "use_umbrella").

rule import-life-cycle-tasks
    ->
(import "GiveBirth")
(import "Die").
