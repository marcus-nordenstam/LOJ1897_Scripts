
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


# Umbrella behaviour

# While it's raining, and we're not inside a structure, use an umbrella
rule use_umbrella-propose
{@self region ?region}
{?region rain !none}
{@self control [k umbrella]:?umbrella} 
(in /not @self [k structure])
    ->
(beginProposal {@self use_umbrella ?umbrella}).

# Take a stowed umbrella into our right hand
rule use_umbrella-propose-TAKE
{@self use_umbrella ?umbrella}
# @self directly controlling something means it is stowed, not in my hand
{@self control ?umbrella} 
{@self hand [k rightHand]:?hand}
{?hand control @nothing}
    ->
# TAKE action will remove self-control and set ?hand to be the controlling entity
(maintainProposal {@self TAKE ?umbrella ?hand}).

# Keep arm bent while holding umbrella
rule use_umbrella-BENT_RIGHT_ARM
{@self use_umbrella}
{@self hand [k rightHand]:?hand}
{?hand control [k umbrella]}
    ->
(maintainProposal {@self BENT_RIGHT_ARM}).

# Stop using an umbrella if it stops raining or
# we're inside a building
rule use_umbrella-STOW
{@self use_umbrella ?umbrella}: ?use_umbrella
{@self region ?region}
{?region rain ?rain}
(or (eq ?rain none) (in /cont @self [k structure]))
    ->
(beginProposal {@self STOW ?umbrella}).


rule use_umbrella-outcome
{@self use_umbrella ?umbrella}: ?use_umbrella
{@self /ever STOW ?umbrella /causes ~?use_umbrella}
    ->
(setOutcome /succ ?use_umbrella).



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


