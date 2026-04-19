
rule seek_answers
{@self get_acquainted_with ?person}
    ->
#(print [@self wants to get to know ?person])
[(qs (any {?person name}).target)
 (qs (any {?person mother}).target)
 (qs (any {?person father}).target)
 (qs (any {?person spouse}).target)
 (qs (any {?person home}).target)]: ?questions
(maintainProposal {@self seek_answers ?questions}).


rule get-acquainted-with-outcome
{@self /ever get_acquainted_with ?person /noOut}: ?getAcquainted
{@self /past seek_answers ? /causes ~?getAcquainted}: ?seek_answers
    ->
(setOutcome ?getAcquainted /from ?seek_answers).

