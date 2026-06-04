; ----------------------------------------------------------------------------
; Employment life-cycle (Phase 7): hiring, promotion, job loss, retirement.
; All operate through the hsim_org_lifecycle verbs; "employed" is the presence
; of an ongoing {@self employer ?} belief, "rank" is the level belief on the
; worker's job object (read via job-level / job-tenure).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; --- hiring: a jobless working-age adult is taken on by some org -------------
(hsim-event hiring
  (nl         "?worker is hired")
  (kind       _hiring)
  (schedule   (annually march))
  (rng-stream employment)

  (roles
    ;; Employers favour character: scandalous applicants are not hired, and the
    ;; chance is honesty-weighted (an honest worker is preferred). The
    ;; (not (= ...)) form is permissive when the situation is unknown - a
    ;; jobless adult appraised before december reads @fail, not scandalous,
    ;; and is not excluded. The honesty multiplier uses (+ 0.5 ...) over a
    ;; 0..1 normalisation so the chance is non-zero even when honesty is
    ;; not yet derived (the F3 cascade returns 0 for an unmemoised dimension,
    ;; and the arithmetic on @fail short-circuits to 0; the constant base
    ;; preserves the prior fire rate).
    (role ?worker (template any_human)
                  (>= (years-old ?self) 16)
                  (<= (years-old ?self) 55)
                  (not (believes ?self {@self employer ?}))
                  (not (= (situation ?self respectability_situation) scandalous))
                  (chance 0.3))
    (role ?articles (template org_articles)))

  (effects
    (hire :articles ?articles :worker ?worker :role clerk :level apprentice)
    (log _hiring ?worker)))

; --- promotion: a worker of three-plus years at rank rises one grade --------
;; Promotion weighs honest, diligent character. A scandalous worker is not
;; promoted; the base chance is scaled by the diligence dimension so a worker
;; well below the population mean is rarely advanced and an exemplary one
;; rises faster. (+ 0.5 (/ diligence 100)) maps a 0..100 dimension to
;; 0.5..1.5; an unmemoised dimension reads @fail and the arithmetic falls
;; through to 0.5 (the engine's non-number short-circuits the / to 0, leaving
;; the mid-range chance the worker had before Phase 9).
(hsim-event promotion
  (nl         "?worker is promoted")
  (kind       _promotion)
  (schedule   (annually march))
  (rng-stream employment)

  (roles
    (role ?worker (template any_human)
                  (believes ?self {@self employer ?})
                  (not (= (job-level ?self) org_head))
                  (>= (job-tenure ?self) 3)
                  ;; S4: a worker must have EARNED competence (>= trained, ~5yr in
                  ;; the job's domain) before rising. Jobs that confer no domain
                  ;; (unskilled trades) pass the gate unconditionally.
                  (job-skilled-at-or-above ?self trained)
                  (not (= (situation ?self respectability_situation) scandalous))
                  (chance (* 0.25 (+ 0.5 (situation ?self diligence))))))

  (effects
    (promote :worker ?worker)
    (log _promotion ?worker)))

; --- job_loss: an employed worker is let go (low monthly rate) --------------
(hsim-event job_loss
  (nl         "?worker loses their job")
  (kind       _job_loss)
  (schedule   (monthly))
  (rng-stream employment)

  (roles
    (role ?worker (template any_human)
                  (believes ?self {@self employer ?})
                  (chance 0.003)))

  (effects
    (fire :worker ?worker)
    (log _job_loss ?worker)))

; --- retirement: an employed worker of 65+ leaves working life --------------
(hsim-event retirement
  (nl         "?worker retires")
  (kind       _retirement)
  (schedule   (annually january))
  (rng-stream employment)

  (roles
    (role ?worker (template any_human)
                  (believes ?self {@self employer ?})
                  (>= (years-old ?self) 65)
                  (chance 0.4)))

  (effects
    (fire :worker ?worker)
    (log _retirement ?worker)))
