
rule nourishmentTasks
    ->
(import "Drink").

rule importMovementTasks 
    ->
(import "Go")
(import "keep_near_and_facing")
(import "MaintainLookingAt")
(import "Explore")
(import "Locate")
(import "GoHome").


rule importResourceTasks 
    ->
(import "Give")
(import "Receive")
(import "Get")
(import "Take")
(import "BuyBuilding").


rule importLearningTasks
    ->
(import "IdentifyPerson")
(import "SeekAnswers")
(import "GetAcquaintedWith")
(import "find_out")
(import "Read")
(import "PerceiveAttr").


rule importSocialTasks
    -> 
(import "Ask")
(import "AnswerQuestion")
(import "HearAnswer")
(import "Tell")
(import "HearTell")
(import "WriteDoc")
(import "Introduce")
(import "Conversation")
(import "Socialize")
(import "Pubbing").


rule importStackTasks
    ->
(import "StackBrowse")
(import "StackGet")
(import "StackPut")
(import "StackRead")
(import "MakeDoneStack").


rule importFamilyTasks
    ->
(import "Engagement")
(import "Marriage")
(import "Parenting").


rule importProfessionalTasks
    ->
(import "Work")
(import "FoundOrg")
(import "HouseAgentClerkJob")
(import "Bartending").

rule importEmotionalTasks
    ->
(import "Grieve").

rule importWeatherTasks
    ->
(import "use_umbrella").

rule importLifeCycleTasks
    ->
(import "GiveBirth")
(import "Die").
