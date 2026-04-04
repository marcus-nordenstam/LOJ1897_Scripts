
# Transactions, giving, taking etc
rule ->
(import "ACQUIRE")
(import "POUR")
(import "CLAIM_TRANSACTION_STATION")
(import "RELEASE_TRANSACTION_STATION")
(import "SET_PROVIDER_OCCUPIER_SLOT")
(import "OFFER")
(import "SPAWN")
(import "LEFT_REACH_FOR")
(import "RIGHT_REACH_FOR")
(import "LEFT_GRASP")
(import "RIGHT_GRASP").

# Communication
rule ->
(import "ASK")
(import "TELL")
(import "WRITE_DOC")
(import "READ").

# Life-cycle
rule ->
(import "HAVE_SEX_WITH")
(import "GIVE_BIRTH")
(import "DIE").

# Movement
rule ->
(import "WALK_TO")
(import "TURN_TO")
(import "MIRROR").

# Perception
rule ->
(import "LOOK_AT")
(import "PERCEIVE_ATTR").

# Drinking
rule ->
(import "RIGHT_ARM_DRINK")
(import "LEFT_ARM_DRINK")
(import "RIGHT_HAND_DRINK")
(import "LEFT_HAND_DRINK")
(import "TILT_BACK_HEAD")
(import "OPEN_JAW").

# Apparel, clothing, carrying etc
rule ->
(import "WEAR").

# Activities
rule ->
(import "START_PERFORMING")
(import "STOP_PERFORMING")
(import "MAKE_CONV_META_ENT")
(import "DESTROY_CONV_META_ENT").

# Stacks
rule ->
(import "MAKE_DONE_STACK")
(import "STACK_PUT")
(import "STACK_TAKE").
