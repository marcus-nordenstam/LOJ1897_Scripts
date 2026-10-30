; ----------------------------------------------------------------------------
; occasion_macros.mc - shared timing / desirability / date helpers for the
; occasion aspect (the attend task, the wedding vow duty, their drivers). All
; content-free: the prep-lead and the guest's desirability are authored here, the window
; arithmetic is the same in-work-hours the work shifts use, the date test rides
; the generic (time year)/(time month) reads over the occasion's own held-on belief.
; ----------------------------------------------------------------------------

(define-macro attend-prep-lead      () 3)       ; hours before start an attendee sets out
(define-macro wedding-lead-months   () 5)       ; months between planning a wedding and its day
(define-macro dinner-lead-months    () 3)       ; months between planning a dinner party and its day
(define-macro occasion-day          () 15)      ; the day of its month an occasion is set for, before the next lived day
(define-macro occasion-start-hour   () 19)
(define-macro occasion-end-hour     () 23)
(define-macro founding-wedding-first-day () 2)  ; days into the first window before the first founding wedding
(define-macro founding-wedding-days () 5)      ; the window days the founding weddings are spread over
(define-macro attend-crasher-value  () 500.0)    ; a kill-driven crasher's floor within the guest tier
(define-macro attend-guest-base     () 850.0)    ; the willing guest's value within the guest tier





