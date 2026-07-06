; ----------------------------------------------------------------------------
; perpetration_terminals.hs - the goal-action -> terminal metadata table for the
; EVENT-IZED perpetration terminals (the Phase 3(c) terminal decomposition).
;
; attempt_nonlethal.hs crosses the actor's standing goals with these rows via
; (select-joint (over-goals ?action ?victim ?goal) (table perpetration_terminals) ...);
; a pair scores 1 only when the goal's action matches the row's action, so the
; select-joint picks ONE standing goal whose terminal has been event-ized, and the
; resolve-perpetration-terminal macro dispatches on the row's `terminal`.
;
; ONE row per event-ized (action, terminal). Growing this table + the dispatcher
; macro + removing the goal's C++ skip in perpetration.cc is how each further
; terminal moves from the C++ generative loop to .hs. Kept minimal until then.
; ----------------------------------------------------------------------------

(define-table perpetration_terminals
  (fields action terminal)

  ; bribe goal -> pay_off terminal (cash transfer; a pure mint-only act + ledger row).
  (record bribe pay_off)
  ; hurt goal -> harm_non_lethal terminal (a beating; mint-only + a bruise).
  (record hurt harm_non_lethal)
  ; frame goal -> plant_evidence terminal (mint-only + a planted blood_stain).
  (record frame plant_evidence)
  ; coerce goal -> silence_coerce terminal (threaten / blackmail; extort anchor + threat).
  (record coerce silence_coerce)
  ; expose goal -> publish_secret terminal (confront / anonymous letter; gossip cascade).
  (record expose publish_secret)
  ; seduce goal -> consummate terminal (reciprocal lover + HAVE_SEX_WITH; fallen_woman).
  (record seduce consummate)
  ; confess_letter goal -> confess_secret terminal (the liaison confessed to kin;
  ; the confession_letter spawns at the kin's home; kills blackmail leverage).
  (record confess_letter confess_secret)
  ; humiliate goal -> public_slight terminal (the two-sided incident anchor +
  ; witnesses; degrade_act construals on the victim's copy).
  (record humiliate public_slight)
  ; report_crime goal -> file_report terminal (the lawful channel - no ledger
  ; row; the crime_report_letter is the PLAYER's case feed).
  (record report_crime file_report))
