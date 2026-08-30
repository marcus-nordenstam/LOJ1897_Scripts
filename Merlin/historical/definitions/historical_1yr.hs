; ----------------------------------------------------------------------------
; historical_1yr.hs - 1-year debug smoke config. A fast (<2min in debug) assert
; check: loads the catalog + runs a full year so parse-time and early-firing
; asserts surface. Release validation uses the 5yr / 10yr configs for byte
; comparison; this exists only so the slower debug build stays under the 2-minute
; watchdog.
; ----------------------------------------------------------------------------

(define-list config seed 4242 start_year 1700 end_year 1700 start_population 50)
