; ----------------------------------------------------------------------------
; immigrant_tables.hs - the authored immigrant model's row data, consumed by
; the (spawn-immigrant ...) world verb via table-name kwargs (the
; spawn-immigrant-wave macro in tunables.hs composes them).
; ----------------------------------------------------------------------------

; Military rank ladder for demobbed/serving male immigrants: mostly privates,
; a thin officer tail (the gentry-born fallen-officer - the Moran case). The
; band scales the martial skilled_in the service conferred.
(define-table immigrant_ranks
  (fields rank band weight)
  (record [k military_rank private]    [k competence_level trained] 0.46)
  (record [k military_rank corporal]   [k competence_level trained] 0.22)
  (record [k military_rank sergeant]   [k competence_level expert]  0.16)
  (record [k military_rank ensign]     [k competence_level trained] 0.06)
  (record [k military_rank lieutenant] [k competence_level expert]  0.05)
  (record [k military_rank captain]    [k competence_level expert]  0.03)
  (record [k military_rank major]      [k competence_level expert]  0.015)
  (record [k military_rank colonel]    [k competence_level expert]  0.005))

; Where the newcomers hail from (weighted).
(define-table immigrant_origins
  (fields nation weight)
  (record english 1)
  (record irish   1))

; The marginal stratum's work, per gender (weighted within gender): kinless
; AND in employer-less marginal work - the socially invisible arrivals the
; predation vulnerability scorer hunts.
(define-table immigrant_marginal_jobs
  (fields gender job weight)
  (record [k female] [k prostitute]     1)
  (record [k male]   [k vagrant]        1)
  (record [k male]   [k casual_laborer] 1))
