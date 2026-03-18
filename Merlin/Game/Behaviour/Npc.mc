
# NPCs have common sense
rule ->
(import "CommonReasoning")
(import "CommonActions")
(import "CommonTasks").


# Startup behaviour

rule go-to-waypoint
{?waypoint isa [k waypoint]}
(isWithinReachOf /not ?waypoint /cont)
    ->
(maintainProposal {@self go ?waypoint}).
#(maintainProposal {@self CHAT})
#(maintainProposal {@self HOLD_UMBRELLA})
#.

#rule propose-use_umbrella
#{@self in [k region]:?region}
#{?region weather ?weather}
#{?weather rain !none}
#    ->
#(maintainProposal {@self use_umbrella}).

rule propose-use_umbrella-take
#{@self use_umbrella}
{@self control [k umbrella]:?umbrella}
{@self hand [k rightHand]:?rhand}
(none {?rhand control ?umbrella})
    ->
(beginProposal {@self TAKE ?umbrella ?rhand}).

rule propose-use_umbrella-bent-right-arm
#{@self use_umbrella}
{@self hand [k rightHand]:?rhand}
{?rhand control [k umbrella]:?umbrella}
    ->
(maintainProposal {@self BENT_RIGHT_ARM}).

rule grieve
{@self /ever love ?person}
#{?person /ever condition dead}
    ->
(maintainProposal {@self grieve}).

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


