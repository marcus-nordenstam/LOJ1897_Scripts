

rule drink-left-ACTION-proposals
{@self drink ?glass}
{@self hand [k left_hand]:?hand}
{?hand control ?glass}
{?glass control [k fluid]:?fluid}
    ->
(maintain_proposal {@self LEFT_ARM_DRINK})
(maintain_proposal {@self LEFT_HAND_DRINK})
(maintain_proposal {@self OPEN_JAW}         (des run 0.6) (des in_out 1.0 0.9))
(maintain_proposal {@self TILT_BACK_HEAD}   (des run 0.3) (des in_out 1.2 0.7) (des preroll 0.3))
(maintain_proposal {@self INGEST ?fluid}    (des preroll 1)).

rule drink-right-ACTION-proposals
{@self drink ?glass}
{@self hand [k right_hand]:?hand}
{?hand control ?glass}
{?glass control [k fluid]:?fluid}
    ->
(maintain_proposal {@self RIGHT_ARM_DRINK})
(maintain_proposal {@self RIGHT_HAND_DRINK})
(maintain_proposal {@self OPEN_JAW}         (des run 0.6) (des in_out 1.0 0.9))
(maintain_proposal {@self TILT_BACK_HEAD}   (des run 0.3) (des in_out 1.2 0.7) (des preroll 0.3))
(maintain_proposal {@self INGEST ?fluid}    (des preroll 1)).

rule drink-outcome
{@self drink ?glass}: ?drink
(gt (time_since /seconds ?drink) 3)
    ->
(set_outcome /succ ?drink).


