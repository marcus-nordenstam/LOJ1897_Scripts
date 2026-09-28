; ----------------------------------------------------------------------------
; occasion_macros.mc - shared timing / desirability / date helpers for the
; occasion aspect (the attend task, the wedding vow duty, their drivers). All
; content-free: the prep-lead and the guest's desirability are authored here, the window
; arithmetic is the same in-work-hours the work shifts use, the date test rides
; the generic (time year)/(time month) reads over the occasion's own held-on belief.
; ----------------------------------------------------------------------------

(define-macro attend-prep-lead      () 3)       ; hours before start an attendee sets out
(define-macro attend-crasher-value  () 500.0)    ; a kill-driven crasher's floor within the guest tier
(define-macro attend-guest-base     () 850.0)    ; the willing guest's value within the guest tier





