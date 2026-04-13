
# --- keep_looking_at_part: look at a specific body part ---
# One rule per body part to keep alpha memories tight.
# We pass the body-part ENTITY (not OBB) as the LOOK_AT target so that the
# game engine can read the live environment position every frame.

rule maintain-lookingAtPart-attention
{@self keep_looking_at_part ?thing ?part}
    ->
(maintainAttention ?thing).

rule maintain-lookingAtPart-eyes-proposal
{@self keep_looking_at_part ?thing eyes}
{?thing eyes @something:?bodyPart}
    ->
(maintainProposal {@self LOOK_AT ?bodyPart}).

rule maintain-lookingAtPart-left_hand-proposal
{@self keep_looking_at_part ?thing left_hand}
{?thing hand [k left_hand]:?bodyPart}
    ->
(maintainProposal {@self LOOK_AT ?bodyPart}).

rule maintain-lookingAtPart-right_hand-proposal
{@self keep_looking_at_part ?thing right_hand}
{?thing hand [k right_hand]:?bodyPart}
    ->
(maintainProposal {@self LOOK_AT ?bodyPart}).

# --- keep_looking_at_whole: look at the entity's own OBB ---
# Here we pass the entity itself, not the OBB, for the same reason.

rule maintain-lookingAtWhole-attention
{@self keep_looking_at_whole ?thing}
    ->
(maintainAttention ?thing).

rule maintain-lookingAtWhole-proposal
{@self keep_looking_at_whole ?thing}
    ->
(maintainProposal {@self LOOK_AT ?thing}).
