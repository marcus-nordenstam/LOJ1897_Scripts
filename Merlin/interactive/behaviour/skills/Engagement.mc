

rule goal-know-answer-to-marriage-proposal
{@self goal {@self marry ?prospect}}: ?iWantToMarryHer
{@self gender male}
{@self marital_state single}
#(none {?prospect goal {@prospect marry @self}})
#(gt (time_since /cont /weeks ?iWantToMarryHer) 1) # had her in mind for 1 week
(lock_rule) # synchronize the ability to activate this rule - only one at a time
    ->
'(prob {?prospect goal {?prospect marry @self}}): ?marriageProposal
(maintain_goal {@self know ?marriageProposal}).


rule reasoning-marriage-proposal-accepted
{?proposer /succ ASK (qs (prob {?proposee goal {?proposee marry ?proposer}})) ?proposee}: ?marriageProposal
{?proposee /succ TELL (msg @true) ?proposer /causes ~?marriageProposal}
    ->
(begin_belief {?proposer fiancee ?proposee})
(begin_belief {?proposee fiancee ?proposer})
(fire_and_forget).


rule reasoning-marriage-proposal-rejected
{?proposer /succ ASK (qs (prob {!@self:?proposee goal {?proposee marry ?proposer}})) ?proposee}: ?marriageProposal
{?proposee /succ TELL (msg @unknown%) ?proposer /causes ~?marriageProposal}
    ->
(begin_belief {?proposee goal {?proposee marry ?proposer} /p @unknown%})
(if (eq ?proposer @self) 
    [(set_outcome {@self goal {@self marry ?proposee}} /fail)
     (any {?proposee marriage_desirability}): ?desirabilityEvent
     (sub ?desirabilityEvent.target 0.1): ?newDesirability
     (begin_belief {?proposee marriage_desirability ?newDesirability})])
(fire_and_forget).



rule goal-possess-engagement-ring
{@self goal {@self marry ?fiancee}}
{@self fiancee ?fiancee}
{@self gender female}
{?fiancee hand ?hand}
{?hand control [k engagement_ring]:?ring}
    ->
(maintain_goal {@self possess ?ring})
(print [@self wants to possess ?ring]).


rule proposal-give-engagement-ring
{@self goal {@self marry ?fiancee}}
{@self fiancee ?fiancee}
{@self gender male}
{@self hand ?hand}
{?hand control [k engagement_ring]:?ring}
(lock_rule)
    ->
(maintain_proposal {@self give ?ring ?fiancee}).


rule proposal-wear-engagement-ring
{@self goal {@self marry ?fiancee}}
{@self fiancee ?fiancee}
{@self gender female}
{@self hand ?hand}
{?hand control [k engagement_ring]:?ring}
{?fiancee /succ give ?ring @self}
{@self hand [k left_hand]:?lhand}
{?lhand finger [k ring_finger]:?ring_finger}
    ->
(begin_belief {?ring owner @self})
(maintain_proposal {@self WEAR ?ring ?ring_finger}).
