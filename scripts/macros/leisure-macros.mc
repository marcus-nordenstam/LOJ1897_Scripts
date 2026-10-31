; ----------------------------------------------------------------------------
; leisure-macros.mc - the rates and band thresholds of the three leisure drives
; (funcs/leisure-drives.mc), per waking hour unless named otherwise.
; ----------------------------------------------------------------------------

; STRAIN, 0 fresh .. 1 worn out: a day's toil strains an average man by the afternoon and frays him
; by a long evening's end; an hour at rest takes off what two hours of toil put on.
(define-macro strain-toil-per-hour () 0.08)
(define-macro strain-rest-per-hour () 0.15)
(define-macro strain-ease-per-hour () 0.08)
(define-macro strain-stress-gain () 1.0)
(define-macro strained-min () 0.4)
(define-macro frayed-min () 0.75)

; TEDIUM, 0 engaged .. 1 restless: a waking day with nothing new in it bores him by the evening.
(define-macro tedium-per-waking-hour () 0.05)
(define-macro tedium-play-relief-per-hour () 0.3)
(define-macro tedium-social-relief-per-hour () 0.1)
(define-macro tedium-devotion-relief-per-hour () 0.05)
(define-macro tedium-sleep-relief-per-hour () 0.1)
(define-macro bored-min () 0.5)
(define-macro restless-min () 0.8)

; SOCIAL-HUNGER, -1 crowded .. 1 isolated: a waking day without a word with anyone leaves an
; average man lonely; an hour's talk with a friend satisfies a day's hunger, and below zero each
; social hour wears him toward crowded.
(define-macro social-hunger-per-waking-hour () 0.03)
(define-macro social-relief-per-hour () 0.5)
(define-macro solitude-recovery-per-hour () 0.25)
(define-macro lonely-min () 0.45)
(define-macro isolated-min () 0.8)
(define-macro companionable-min () -0.5)
; Crowded stays until he has recovered this far: a few minutes alone do not undo it.
(define-macro companionable-recovered-min () -0.2)
; The share of his crowding an average man still carries after a night's sleep; an introvert keeps
; more of it, an extravert less (times (sociability-max - sociability)).
(define-macro sleep-crowding-kept () 0.3)

; A trait's swing on a drive's rate, and the bounds every rate multiplier is clamped to.
(define-macro leisure-trait-swing () 0.5)
(define-macro leisure-rate-mult-min () 0.25)
(define-macro leisure-rate-mult-max () 2.0)

; What a company drive bids within the want band: the band's own level times his sociability.
(define-macro company-want-value () 500.0)
(define-macro lonely-company-level () 0.6)
(define-macro isolated-company-level () 1.0)
(define-macro sociability-max () 2.0)

; How much keener company is to a lonely or an isolated man than to one who has had enough.
(define-macro lonely-appetite () 1.5)
(define-macro isolated-appetite () 2.0)

; What resting bids within the want band, strained and frayed.
(define-macro strained-rest-value () 250.0)
(define-macro frayed-rest-value () 450.0)
