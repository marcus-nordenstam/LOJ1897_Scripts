
rule import-reasoning ->
(import "Age")
(import "MarriageProspect")
(import "Family")
(import "Death")
(import "InferMaritalState").


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
(import "TellAnswer")
(import "HearAnswer")
(import "HearTell")
(import "TellAbout")
(import "TellBeliefs")
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



# Startup behaviour

# Everyone but the bartender starts out pubbing
rule startup-go-pubbing
{@self isa [k human]}
(none {@self job [k bartender]})
    ->
(begin_proposal {@self pubbing} (des abs_util 10)).


# Enter pub behaviour

rule startup-go-to-pub
{?pub isa [k building pub]}
(in @self /not ?pub)
(none {@self job [k bartender]})
    ->
(maintain_proposal {@self enter ?pub}).


rule enter-container-go-nearby
{@self enter [k container_structure]:?container}
{?container part [k opening]:?opening}
(gt (distance @self ?opening) 10)
(env_cell (des in_front_of ?opening) /debug): ?nearby_cell
(lock_rule enter 1)
    ->
(maintain_proposal {@self go_env_cell ?nearby_cell}).


rule enter-container-go-through-opening
{@self enter [k container_structure]:?container}
(lock_rule enter 0)
(maintain_claim_env_cell (des inside ?container)): ?enter_cell
(overlaps /not ?enter_cell @self 1)
    ->
(maintain_proposal {@self go_env_cell ?enter_cell}).


# Emotional reactions

rule grieve
{@self /ever love ?person}
#{?person /ever condition dead}
    ->
# Grieving is an emotion-task which should not compete with regular tasks
# So it should only express itself if there's nothing else going on
(maintain_proposal {@self grieve} (des abs_util -10000)).

#rule go-to-waypoint
#{?waypoint isa [k waypoint]}
#    ->
#(elapsed_firing_cycles /cont): ?cycles
#(if (gt ?cycles 700)
#    (maintain_proposal {@self go_entity ?waypoint})
#    (maintain_proposal {@self CHAT})).

#rule go-to-waypoint
#{?waypoint isa [k waypoint]}
#    ->
#(maintain_proposal {@self go_entity ?waypoint}).


rule start-performing-job
{@self job [k bartender]:?job ?pub}
{@self control [k umbrella]:?umbrella} 
    ->
(begin_proposal {@self START_PERFORMING [k bartending] ?pub})
(begin_proposal {@self STOW ?umbrella}).



/*


maybe eliminate container_structure and just use structure
each kind can flag if it has its own local path-grid or should be stamped into the world grid.

individually placed trees, large rocks, hedges, lamp-posts, poles, fences, etc.
a forest: many trees. each forest is unique, so no kind sharing here.

moving entities: human, horse, wagon, train, ship

natural barriers: could be done via splines instead of grid?

if an NPC is pathing across the world, any entity with a local path-grid is NOT stamped into world-grid and thus
invisible to the world-pathing.  so the world-pathing must simply treat the OBB of those are blocked.  that means
path-finding would have to test every expanded cell if its inside the OBB.  alternatively, it rasterizes the OBB
onto the world-grid temporarily.  

finding an available space to claim: (to put something there, to place oneself there as a pathfinding destination, etc)
pathfinding: seeking a clear route through a space


*/