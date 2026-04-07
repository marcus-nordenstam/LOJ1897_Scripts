
# NPCs have common sense
rule ->
(import "CommonReasoning")
(import "CommonTasks").


# Startup behaviour

# Everyone but the bartender starts out pubbing
rule startup-go-pubbing
{@self isa [k human]}
(none {@self job [k bartender]})
    ->
(beginProposal {@self pubbing} /absUtil 10).


# Waypoint behaviour

rule startup-go-to-waypoint
{?waypoint isa [k waypoint]}
(isWithinReachOf /not ?waypoint /cont)
(none {@self job [k bartender]})
(in @self /not [k building pub])
    ->
(maintainProposal {@self go ?waypoint}).


# Emotional reactions

rule grieve
{@self /ever love ?person}
#{?person /ever condition dead}
    ->
# Grieving is an emotion-task which should not compete with regular tasks
# So it should only express itself if there's nothing else going on
(maintainProposal {@self grieve} /absUtil -10000).

#rule go-to-waypoint
#{?waypoint isa [k waypoint]}
#    ->
#(elapsedFiringCycles /cont): ?cycles
#(if (gt ?cycles 700)
#    (maintainProposal {@self go ?waypoint})
#    (maintainProposal {@self CHAT})).

#rule go-to-waypoint
#{?waypoint isa [k waypoint]}
#    ->
#(maintainProposal {@self go ?waypoint}).


rule start-performing-job
{@self job [k bartender]:?job ?pub}
{@self control [k umbrella]:?umbrella} 
    ->
(beginProposal {@self START_PERFORMING [k bartending] ?pub})
(beginProposal {@self STOW ?umbrella}).
