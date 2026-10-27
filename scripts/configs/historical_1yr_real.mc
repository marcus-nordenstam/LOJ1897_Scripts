; ----------------------------------------------------------------------------
; historical_1yr_real.mc - the town on the REAL clock, frame by frame, no history: the
; Player's clock run headless (msim) or in the studio. A real-clock run is presented round
; one NPC, the `player` role town-real-startup casts; mstudio may re-centre it.
; ----------------------------------------------------------------------------

(define-list config
  seeds 4242
  start 1700-01-01
  end 1700-12-31
  clock real
  fps uncapped
  presented player
  level "Theatres/demo_tech_level_v2.grs"
  startup town-real-startup)
