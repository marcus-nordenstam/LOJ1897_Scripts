
# --- keep_looking_at_part: look at a specific body part ---
# One rule per body part to keep alpha memories tight.
# We pass the body-part ENTITY (not OBB) as the LOOK_AT target so that the
# game engine can read the live environment position every frame.

rule maintain-looking-at-part-attention
{@self keep_looking_at_part ?thing ?part}
    ->
(maintain_attention ?thing).

rule maintain-looking-at-part-eyes-proposal
{@self keep_looking_at_part ?thing eyes}
{?thing eyes @something:?bodyPart}
    ->
(maintain_proposal {@self LOOK_AT ?bodyPart}).

rule maintain-looking-at-part-left_hand-proposal
{@self keep_looking_at_part ?thing left_hand}
{?thing hand [k left_hand]:?bodyPart}
    ->
(maintain_proposal {@self LOOK_AT ?bodyPart}).

rule maintain-looking-at-part-right_hand-proposal
{@self keep_looking_at_part ?thing right_hand}
{?thing hand [k right_hand]:?bodyPart}
    ->
(maintain_proposal {@self LOOK_AT ?bodyPart}).

# --- keep_looking_at_whole: look at the entity ---

rule maintain-looking-at-whole-attention
{@self keep_looking_at_whole ?thing}
    ->
(maintain_attention ?thing).

rule maintain-looking-at-whole-proposal
{@self keep_looking_at_whole ?thing}
    ->
(maintain_proposal {@self LOOK_AT ?thing}).
