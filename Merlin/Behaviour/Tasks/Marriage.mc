
# Marriage starts once the groom has acquired a new home

rule marry-seek-home-for-spouse
{@self fiancee @something:?fiancee}
{@self gender male}
{@self parent ?parent}
{?parent condition alive}
{?parent home ?parentHome}
{@self home ?parentHome}
(lockRule)
    ->
(beginGoal {@self home (o /invent [k residential_building])}).


rule marry-acquire-home-proposal
{@self goal {@self home ?irrHome}}
{?irrHome isa [k building]:?bldgKind}
    ->
(maintainProposal {@self ACQUIRE ?bldgKind}).


rule marry-acquire-home-outcome
{@self goal {@self home ?irrHome}}: ?goal
{?irrHome isa [k building]:?bldgKind}
{@self /succ ACQUIRE ?bldgKind /causes ~?goal}
    ->
(setOutcome /succ ?goal).



rule marry-proposal
{@self goal {@self marry ?fiancee}}
{@self fiancee ?fiancee}
{@self gender male}
{@self parent ?parent}
{?parent condition alive}
{?parent home ?parentHome}
{@self home !?parentHome:?myHome}
{?myHome obb ?myHomeObb}
(lockRule)
    ->
(beginProposal {@self marry ?fiancee})
(beginProposal {@self SPAWN [[k wedding_band] @self]})
(beginGoal {@self TELL (msg {@self home ?myHome}) ?fiancee})
(beginGoal {@self TELL (msg {?myHome obb ?myHomeObb}) ?fiancee}).


rule marry-attention
{@self marry ?fiancee}
    ->
(maintainAttention ?fiancee).
#(maintainProposal {@self keep_near_and_facing ?fiancee} (abs_util 1000)).


rule marry-give-wedding-band
{@self marry ?fiancee}
{@self gender male}
{[k wedding_band]:?wedding_band owner @self}
{?fiancee hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
(none {?ring_finger wear [k wedding_band]})
    ->
(beginBelief {?wedding_band owner ?fiancee})
(beginProposal {@self give ?wedding_band ?fiancee}).


# BRIDE behaviour
rule female-marry
{@self fiancee @something:?fiancee}
{@self gender female}
{?fiancee OFFER [k wedding_band]:?wedding_band @self}
    ->
(beginProposal {@self marry ?fiancee})
(maintainGoal {@self possess ?wedding_band}).


rule female-marry-wear-wedding-band
{@self marry ?fiancee}
{?fiancee home ?fianceeHome}
{@self gender female}
{@self hand ?hand}
{?hand control [k wedding_band]:?ring}
{?fiancee /succ give ?ring @self}
{@self hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
    ->
(beginBelief {?ring owner @self})
(maintainProposal {@self WEAR ?ring ?ring_finger})
(beginBelief {@self home ?fianceeHome}).


# GROOM behaviour
rule marry-conjure-groom-wedding-band
{@self marry ?fiancee}
{?fiancee hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
{?ring_finger wear [k wedding_band]}
    ->
(beginProposal {@self SPAWN [[k wedding_band] @self (floats 0.2 1 1) (floats 0 0 0 1)]}).

rule marry-groom-wear-wedding-band
{@self marry ?fiancee}
{?fiancee hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
{?ring_finger wear [k wedding_band]}
{[k wedding_band]:?myRing owner @self}
{@self hand [k left_hand]:?myLeftHand}
{?myLeftHand finger [k ring_finger]:?myRingFinger}
(none {?myLeftHand wear ?myRing})
    ->
(maintainProposal {@self WEAR ?myRing ?myRingFinger}).


# Rules for both BRIDE & GROOM
rule marry-outcome-succ
{@self marry ?fiancee}: ?marry
{?fiancee hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
{?ring_finger wear [k wedding_band]}
{@self hand [k left_hand]:?myLeftHand}
{?myLeftHand finger [k ring_finger]:?myRingFinger}
{?myRingFinger wear [k wedding_band]}
    ->
(setOutcome /succ ?marry)
(endBelief {@self fiancee ?fiancee})
(beginBelief {@self spouse ?fiancee}).



# PUTTING PARENTS HOUSE BACK ON THE MARKET






/*

rule 
{@self fiancee @something:?fiancee}
{@self gender male}
{?wedding_band isa [k wedding_band]}
{@self hand [k left_hand]:?lhand}
{@self hand [k right_hand]:?rhand}
(none {? control ?wedding_band})
    ->
(maintainProposal {@self take ?wedding_band}).

*/