
# I can infer the martial status of anyone by considering the known spouse/fiancee relationships

rule inferSingle
{?person fiancee @nothing}
{?person spouse @nothing}
#{?person age_group >2}
{?person age_group >0}
    ->
(beginBelief {?person marital_state single})
(print [@self infers that ?person is single])
(fireAndForget).

rule inferEngaged
{?person fiancee @something}
{?person spouse @nothing}
    ->
(beginBelief {?person marital_state engaged})
(print [@self infers that ?person is engaged])
(fireAndForget).

rule inferMarried
{?person spouse @something}
    ->
(beginBelief {?person marital_state married})
(print [@self infers that ?person is married])
(fireAndForget).


# You can infer spouse/fiancee relationships of OTHERS by examining the rings on the person's left hand ringfinger

# If the person is a female and NOT wearing an engagement-ring, then she's NOT engaged
# If the person is male, well, they never wear engagement-rings, so we'll just optimistically believe they're NOT engaged as well.
rule inferNoFiancee
{@self infer {?person marital_state}}
{?person hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
(none {?ring_finger wear [k engagement_ring]})
    ->
(beginBelief {?person fiancee @nothing}).


# If the person, regardless of gender, is NOT wearing a wedding-band, then they're NOT married
rule inferNoSpouse
{@self infer {?person marital_state}}
{?person hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
(none {?ring_finger wear [k wedding_band]})
    ->
(beginBelief {?person spouse @nothing}).


# If the person is female and wears an engagement-ring (but no wedding-band), then she's engaged
rule inferFiancee
{@self infer {?person marital_state}}
{?person gender female}
{?person hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
{?ring_finger wear [k engagement_ring]}
(none {?ring_finger wear [k wedding_band]})
    ->
(beginBelief {?person fiancee @something})
(beginBelief {?person spouse @nothing}).


# If the person, regardless of gender, wears a wedding-band, then they're married, and NOT engaged (anymore)
rule inferSpouse
{@self infer {?person marital_state}}
{?person hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
{?ring_finger wear [k wedding_band]}
    ->
(beginBelief {?person fiancee @nothing})
(beginBelief {?person spouse @something}).

