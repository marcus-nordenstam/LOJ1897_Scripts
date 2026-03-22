
# NPCs have common sense
rule ->
(import "CommonReasoning")
(import "CommonActions")
(import "CommonTasks").


# Startup behaviour


# Waypoint behaviour

rule go-to-waypoint
{?waypoint isa [k waypoint]}
(isWithinReachOf /not ?waypoint /cont)
(none {@self job [k bartender]})
    ->
(maintainProposal {@self go ?waypoint}).
#(maintainProposal {@self CHAT})
#(maintainProposal {@self HOLD_UMBRELLA})
#.

/*
# Pub patron behaviour

rule propose-rhand-TAKE-glass
# know this is my beer
{@self hand [k rightHand]:?hand}
{?hand control @nothing}
(none {@self job [k bartender]})
(lockRule take_glass 1) # higher priority than the left-handed take
    ->
(beginProposal {@self TAKE ?glass ?hand})
(beginProposal {@self BENT_RIGHT_ARM}).


rule propose-lhand-TAKE-beer_glass
# know this is my beer
{@self hand [k leftHand]:?hand}
{?hand control @nothing}
(none {@self job [k bartender]})
(lockRule take_glass 0)
    ->
(beginProposal {@self TAKE ?glass ?hand})
(beginProposal {@self BENT_RIGHT_ARM}).

*/


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


