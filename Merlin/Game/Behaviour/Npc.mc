
# NPCs have common sense
rule ->
(import "CommonReasoning")
(import "CommonActions")
(import "CommonTasks").


# Startup behaviour

#rule chat
#{?waypoint isa [k waypoint]}
#    ->
#(maintainProposal {@self CHAT})
#(maintainProposal {@self HOLD_UMBRELLA})
#.

rule grieve
{@self /ever love ?person}
#{?person /ever condition dead}
    ->
(maintainProposal {@self GRIEVE}).

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


