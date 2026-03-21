
# Bear in mind that facing is NOT exclusive

rule maintain-facing-attention
{@self keepFacing ?thing}
    ->
(maintainAttention ?thing).

rule maintain-facing-belief
{@self keepFacing ?thing}
#(print [@self facing ?thing] /cont)
(isFacing ?thing 0.9 /cont) = ?prob
    ->
(maintainBelief {@self facing ?thing /p ?prob}).

rule maintain-facing-turnTo-proposal
{@self keepFacing ?thing}
{@self /not facing ?thing}
    ->
(maintainProposal {@self TURN_TO ?thing}).

rule maintain-facing-locate-proposal
{@self keepFacing ?thing}
{@self facing ?thing /p @unknown%}
    ->
(maintainProposal {@self locate ?thing}).