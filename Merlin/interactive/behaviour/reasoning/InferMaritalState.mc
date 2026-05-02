
# I can infer the martial status of anyone by considering the known spouse/fiancee relationships

rule infer-single
{?person fiancee _}
{?person spouse _}
#{?person age_group >2}
{?person age_group >0}
    ->
(begin_belief {?person marital_state single})
(fire_and_forget).

rule infer-engaged
{?person fiancee @something}
{?person spouse _}
    ->
(begin_belief {?person marital_state engaged})
(fire_and_forget).

rule infer-married
{?person spouse @something}
    ->
(begin_belief {?person marital_state married})
(fire_and_forget).


# You can infer spouse/fiancee relationships of OTHERS by examining the rings on the person's left hand ringfinger

# If the person is a female and NOT wearing an engagement-ring, then she's NOT engaged
# If the person is male, well, they never wear engagement-rings, so we'll just optimistically believe they're NOT engaged as well.
rule infer-no-fiancee
{@self infer {?person marital_state}}
{?person hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
(none {?ring_finger wear [k engagement_ring]})
    ->
(begin_belief {?person fiancee _}).


# If the person, regardless of gender, is NOT wearing a wedding-band, then they're NOT married
rule infer-no-spouse
{@self infer {?person marital_state}}
{?person hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
(none {?ring_finger wear [k wedding_band]})
    ->
(begin_belief {?person spouse _}).


# If the person is female and wears an engagement-ring (but no wedding-band), then she's engaged
rule infer-fiancee
{@self infer {?person marital_state}}
{?person gender female}
{?person hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
{?ring_finger wear [k engagement_ring]}
(none {?ring_finger wear [k wedding_band]})
    ->
(begin_belief {?person fiancee @something})
(begin_belief {?person spouse _}).


# If the person, regardless of gender, wears a wedding-band, then they're married, and NOT engaged (anymore)
rule infer-spouse
{@self infer {?person marital_state}}
{?person hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
{?ring_finger wear [k wedding_band]}
    ->
(begin_belief {?person fiancee _})
(begin_belief {?person spouse @something}).

