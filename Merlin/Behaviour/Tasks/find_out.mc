
#
# Rules for finding things out.
#

# Base Rule: If I want to learn some general aspect about a person, I could ask the person.
#rule /cat learnTarget /rank 0
rule find-out-target-about-person-general
{@self goal {@self know (any {[k human]:?person ? ?}).target:?what} /causes ?causes}
   ->
(maintainGoal {@self ASK (qs ?what) ?person}): ?ask_goal
(addCause ?ask_goal ?causes).

# Specific versions of the know rule -- overrides base rule:

#rule /cat learnTarget /rank 1
#{@self goal {@self know '(any {?person maritalState}).target}}
#    ->
#(maintainProposal {@self infer {?person maritalState}}).



# Base Rule: If I want to learn if something is true about a person, I could ask the person.
#rule /cat learnProb /rank 0
rule find-out-prob-about-person-general
{@self goal {@self know (prob {[k human]:?person ? ?}):?what}}
    ->
(maintainGoal {@self ASK (qs ?what) ?person})
(print [@self will ask (nl (qs ?what)) to ?person]).


# If a person has some relation to an object,
# and I'm trying to learn about that object,
# I can ask the person about it.
#rule 
#{@self goal {@self know '(real {? ? [k human]:?person}):?question}}: ?goal
#(msgContent ?question): ?qsContent
#(eqFuncName ?qsContent real)
#(tail ?qsContent).subject: ?subjects
#(any {?subjects isa [k human]}).subject: ?person
#    ->
#(maintainGoal {@self ASK ?question ?person}).

