; historical_debug.hs - tiny 1-year traced-debug config. Same seed + world as
; historical_5yr but 50 residents and a single year (1700), so a --trace-all run
; stays small AND stays UNDER the 256 contents cap (no venue overflow), completing
; so its .msb + trace bin-log can be queried to see where NPCs actually relocate.

(define-list config seed 4242 start_year 1700 end_year 1701 start_population 50)
