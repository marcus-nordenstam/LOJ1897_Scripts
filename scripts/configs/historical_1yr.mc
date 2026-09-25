; ----------------------------------------------------------------------------
; historical_1yr.mc - 1-year debug smoke config. A fast (<2min in debug) assert
; check: loads the catalog + runs a full year so parse-time and early-firing
; asserts surface. Release validation uses the 5yr / 10yr configs for byte
; comparison; this exists only so the slower debug build stays under the 2-minute
; watchdog.
; ----------------------------------------------------------------------------

(define-list config
  seeds 4242
  start 1700-01-01
  end 1700-12-31
  clock jump
  mwo "Merlin/bin/demo_tech_level_v2.mwo"
  startup town-startup)
