
# Marriage starts once the groom has acquired a new home

rule marry-seek-home-for-spouse
{@self fiancee @something:?fiancee}
{@self gender male}
{@self parent ?parent}
{?parent condition alive}
{?parent home ?parentHome}
{@self home ?parentHome}
(lock_rule)
    ->
(begin_goal {@self home (o /invent [k residential_building])}).


rule marry-acquire-home-proposal
{@self goal {@self home ?irrHome}}
{?irrHome isa [k building]:?bldgKind}
    ->
(maintain_proposal {@self ACQUIRE ?bldgKind}).


rule marry-acquire-home-outcome
{@self goal {@self home ?irrHome}}: ?goal
{?irrHome isa [k building]:?bldgKind}
{@self /succ ACQUIRE ?bldgKind /causes ~?goal}
    ->
(set_outcome /succ ?goal).



rule marry-proposal
{@self goal {@self marry ?fiancee}}
{@self fiancee ?fiancee}
{@self gender male}
{@self parent ?parent}
{?parent condition alive}
{?parent home ?parentHome}
{@self home !?parentHome:?myHome}
{?myHome obb ?myHomeObb}
(lock_rule)
    ->
(begin_proposal {@self marry ?fiancee})
(begin_proposal {@self SPAWN [[k wedding_band] @self]})
(begin_goal {@self TELL (msg {@self home ?myHome}) ?fiancee})
(begin_goal {@self TELL (msg {?myHome obb ?myHomeObb}) ?fiancee}).


rule marry-attention
{@self marry ?fiancee}
    ->
(maintain_attention ?fiancee).
#(maintain_proposal {@self keep_near_and_facing ?fiancee} (des abs_util 1000)).


rule marry-give-wedding-band
{@self marry ?fiancee}
{@self gender male}
{[k wedding_band]:?wedding_band owner @self}
{?fiancee hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
(none {?ring_finger wear [k wedding_band]})
    ->
(begin_belief {?wedding_band owner ?fiancee})
(begin_proposal {@self give ?wedding_band ?fiancee}).


# BRIDE behaviour
rule female-marry
{@self fiancee @something:?fiancee}
{@self gender female}
{?fiancee OFFER [k wedding_band]:?wedding_band @self}
    ->
(begin_proposal {@self marry ?fiancee})
(maintain_goal {@self possess ?wedding_band}).


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
(begin_belief {?ring owner @self})
(maintain_proposal {@self WEAR ?ring ?ring_finger})
(begin_belief {@self home ?fianceeHome}).


# GROOM behaviour
rule marry-conjure-groom-wedding-band
{@self marry ?fiancee}
{?fiancee hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
{?ring_finger wear [k wedding_band]}
    ->
(begin_proposal {@self SPAWN [[k wedding_band] @self (floats 0.2 1 1) (floats 0 0 0 1)]}).

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
(maintain_proposal {@self WEAR ?myRing ?myRingFinger}).


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
(set_outcome /succ ?marry)
(end_belief {@self fiancee ?fiancee})
(begin_belief {@self spouse ?fiancee}).



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
(maintain_proposal {@self take ?wedding_band}).

*/