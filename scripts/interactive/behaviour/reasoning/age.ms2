
rule derive-age-succ
{@self belief_derivation {?thing age}}: ?derive
{?thing birth_date ?birth_date}
    ->
(age ?birth_date): ?age
(begin_belief {?thing age ?age} /forget_when_sleeping)
(end_belief ?derive).

rule derive-age-fail
{@self belief_derivation {?thing age}}: ?derive
(none {?thing birth_date})
    ->
(begin_belief {?thing age @unknown} /forget_when_sleeping)
(end_belief ?derive).