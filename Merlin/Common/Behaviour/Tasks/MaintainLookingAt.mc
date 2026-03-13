
# --- keepLookingAtPart: look at a specific body part ---
# One rule per body part to keep alpha memories tight.
# We pass the body-part ENTITY (not OBB) as the LOOK_AT target so that the
# game engine can read the live environment position every frame.

rule maintain-lookingAtPart-attention
{@self keepLookingAtPart ?thing ?part}
    ->
(maintainAttention ?thing).

rule maintain-lookingAtPart-eyes-proposal
{@self keepLookingAtPart ?thing eyes}
{?thing eyes ?bodyPart}
    ->
(maintainProposal {@self LOOK_AT ?bodyPart}).

rule maintain-lookingAtPart-leftHand-proposal
{@self keepLookingAtPart ?thing leftHand}
{?thing hand [k leftHand]:?bodyPart}
    ->
(maintainProposal {@self LOOK_AT ?bodyPart}).

rule maintain-lookingAtPart-rightHand-proposal
{@self keepLookingAtPart ?thing rightHand}
{?thing hand [k rightHand]:?bodyPart}
    ->
(maintainProposal {@self LOOK_AT ?bodyPart}).

# --- keepLookingAtWhole: look at the entity's own OBB ---
# Here we pass the entity itself, not the OBB, for the same reason.

rule maintain-lookingAtWhole-attention
{@self keepLookingAtWhole ?thing}
    ->
(maintainAttention ?thing).

rule maintain-lookingAtWhole-proposal
{@self keepLookingAtWhole ?thing}
    ->
(maintainProposal {@self LOOK_AT ?thing}).
