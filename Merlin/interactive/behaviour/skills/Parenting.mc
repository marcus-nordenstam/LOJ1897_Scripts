
# If you are married, you'll want kids
rule parenting-grow-family
{@self gender male}
{@self spouse @something:?spouse}
(lt (count (every {@self child})) 3)
    ->
(maintain_proposal {@self HAVE_SEX_WITH ?spouse}).

# We let the mother tell her children about their home
rule parenting-tell-child-their-home
{@self gender female}
{@self home ?home}
{@self child ?child}
{?child age_group 0}
(none {@self /succ TELL (msg {?child home ?home}) ?child})
    ->
(begin_goal {@self TELL (msg {?child home ?home}) ?child})
(fire_and_forget).

rule parenting-tell-child-my-home
{@self child ?child}
{?child age_group 0}
{@self home ?home}
(none {@self /succ TELL (msg {@self home ?home}) ?child})
    ->
(begin_goal {@self TELL (msg {@self home ?home}) ?child})
(fire_and_forget).

# We let the mother introduce the siblings
rule introduce_siblings
{@self gender female}
{@self child ?child1}
{?child1 age_group 0}
{@self child !?child1:?child2}
(none {@self /succ introduce_siblings ?child1 ?child2})
    ->
(maintain_proposal {@self introduce_siblings ?child1 ?child2}).

# Once the children are old enough, tell them about the theatre (so they can go there later and socialize)
rule parenting-tell-child-theatre-obb
{@self gender ?gender}
{@self child ?child}
{?child gender ?gender}
{?child age_group 1}
{?theatre isa [k building theatre]:?theatreKind}
{?theatre obb ?obb}
    ->
(maintain_goal {@self TELL (msg (o ?theatreKind {@o obb ?obb})) ?child}).

# comeWith task:
#   If someone tells you comeWith, they are the leader and I am the follower
#   leader:
#       while follower is near, go to destination
#       when you are at the destination, tell them "we have arrived" which ends the task.
#   follower:
#       while follower is NOT near, go to leader
#       if the leader tells you "we have arrived", the task is done.

