
# While it's raining, and we're not inside a structure, use an umbrella
rule use_umbrella-propose
{@self region ?region}
{?region rain !none}
{@self control [k umbrella]:?umbrella} 
(in /not @self [k structure])
    ->
(beginProposal {@self use_umbrella ?umbrella}).

# Take a stowed umbrella into our right hand
rule use_umbrella-propose-take
{@self use_umbrella ?umbrella}
# @self directly controlling something means it is stowed, not in my hand
{@self control ?umbrella}
{@self hand [k right_hand]:?hand}
{?hand control @nothing}
    ->
# take task will reach for and grasp the umbrella
(maintainProposal {@self take ?umbrella} (abs_util 100)).

# Keep arm bent while holding umbrella
#rule use_umbrella-RIGHT_ARM_OUT
#{@self use_umbrella}
#{@self hand [k right_hand]:?hand}
#{?hand control [k umbrella]}
#    ->
#(maintainProposal {@self RIGHT_ARM_OUT}).

# Stop using an umbrella if it stops raining or
# we're inside a building
rule use_umbrella-STOW
{@self use_umbrella ?umbrella}: ?use_umbrella
{@self region ?region}
{?region rain ?rain}
(or (eq ?rain none) (in @self [k structure]))
    ->
(beginProposal {@self STOW ?umbrella}).


rule use_umbrella-outcome
{@self use_umbrella ?umbrella}: ?use_umbrella
{@self /ever STOW ?umbrella /causes ~?use_umbrella}
    ->
(setOutcome /succ ?use_umbrella).
