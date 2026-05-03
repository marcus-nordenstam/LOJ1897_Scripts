

# Drink: hand controls glass, glass controls fluid -> propose the sided arm/hand
# drink anims plus mouth/head + INGEST. ARM_DRINK and HAND_DRINK are sided on
# their target slots; (side ?hand) selects left vs right motor at install time.
rule drink-ACTION-proposals
{@self drink ?glass}
{@self hand ?hand}
{?hand control ?glass}
{?glass control [k fluid]:?fluid}
    ->
(maintain_proposal {@self ARM_DRINK  (side ?hand)})
(maintain_proposal {@self HAND_DRINK (side ?hand)})
(maintain_proposal {@self OPEN_JAW}         (des run 0.6) (des in_out 1.0 0.9))
(maintain_proposal {@self TILT_BACK_HEAD}   (des run 0.3) (des in_out 1.2 0.7) (des preroll 0.3))
(maintain_proposal {@self INGEST ?fluid}    (des preroll 1)).

rule drink-outcome
{@self drink ?glass}: ?drink
(gt (time_since /seconds ?drink) 3)
    ->
(set_outcome /succ ?drink).
