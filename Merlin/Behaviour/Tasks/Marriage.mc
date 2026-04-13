
# Marriage starts once the groom has acquired a new home

rule seekHomeForSpouse
{@self fiancee @something:?fiancee}
{@self gender male}
{@self parent ?parent}
{?parent condition alive}
{?parent home ?parentHome}
{@self home ?parentHome}
(lockRule)
    ->
(print [@self begins seeking a home])
(beginGoal {@self home (o /invent [k residential_building])}).


rule acquireHome
{@self goal {@self home ?irrHome}}
{?irrHome isa [k building]:?bldgKind}
    ->
(print [@self will acquire ?bldgKind])
(maintainProposal {@self ACQUIRE ?bldgKind}).


rule acquireHomeOutcome
{@self goal {@self home ?irrHome}}: ?goal
{?irrHome isa [k building]:?bldgKind}
{@self /succ ACQUIRE ?bldgKind /causes ~?goal}
    ->
(print [@self no longer seeks a home])
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
#(maintainProposal {@self keep_near_and_facing ?fiancee} /absUtil 1000).


rule marry-giveWeddingBand
{@self marry ?fiancee}
{@self gender male}
{[k wedding_band]:?wedding_band owner @self}
{?fiancee hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
(none {?ring_finger wear [k wedding_band]})
    ->
(beginBelief {?wedding_band owner ?fiancee})
(beginProposal {@self give ?wedding_band ?fiancee})
(print [@self will give ?wedding_band to ?fiancee]).


# BRIDE behaviour
rule female-marry
{@self fiancee @something:?fiancee}
{@self gender female}
{?fiancee OFFER [k wedding_band]:?wedding_band @self}
    ->
(beginProposal {@self marry ?fiancee})
(maintainGoal {@self possess ?wedding_band})
(print [@self wants to possess ?wedding_band]).


rule female-marry-wearWeddingBand
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
(beginBelief {@self home ?fianceeHome})
(print [@self wants to put on wedding_band])
(print (every {?fiancee /ever give})).


# GROOM behaviour
rule conjureGroomWeddingBand
{@self marry ?fiancee}
{?fiancee hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
{?ring_finger wear [k wedding_band]}
    ->
(beginProposal {@self SPAWN [[k wedding_band] @self (floats 0.2 1 1) (floats 0 0 0 1)]}).

rule groomWearWeddingBand
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
rule marriedSuccess
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
(beginBelief {@self spouse ?fiancee})
(print [@self and ?fiancee are married]).



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