; ----------------------------------------------------------------------------
; historical_5yr_50_pop.hs - 5-year validation config (1700-1704, ~50-person town).
; A 50-pop variant of the 5-year span: long enough to exercise the derived-signal
; cascade across several December re-derivations, small enough to avoid the 200-pop
; tell-flood t_sound overflow that historical_5yr.hs (200 pop) hits. Same seed as the
; 2-year config for directly comparable trajectories.
; ----------------------------------------------------------------------------

(seed              4242)
(start_year        1700)
(end_year          1704)
(start_population  50)
