; ----------------------------------------------------------------------------
; hire-applicant ?applicant ?jk - a man is standing at the counter to take up a post of
; kind ?jk: his accept-job-offer is observable and he has named himself. If he is one of
; the men the officer has heard of only on paper, the two accounts are fused first, so the
; promise the officer wrote lands on the man in front of him. Then the book decides:
; a vacant line of his kind and he is signed on and told so (/succ); none, and he is told
; who holds it and turned away (/fail) - first through the door gets the post.
; ----------------------------------------------------------------------------

(npc-task {@self hire-applicant ?applicant ?jk}:?ha-rel
  (track-skill-level [k personnel])
  (tar human)
  (aux [k job])
  (and
    ; THE PAPER MAN AND THE MAN: the officer heard of him off a form - a name, realis and
    ; ungrounded. The man at the counter carries the same name; fuse them, so what was
    ; promised to the one on paper is now known of the one in the room.
    (try
      (role @self {?applicant name ?pname})
      (role ?paper [k human] {?paper name ?pname}
                             (is-reconcilable ?paper)
                             (!= ?paper ?applicant))
      (effects (reconcile ?paper ?applicant)))

    ; SIGN HIM ON: a vacant line of his kind. The act that fills the seat concludes into
    ; the belief that it is filled, so the word below follows in the same round.
    (try
      ; HIRE writes a man standing in front of the book: his reach is this rung's to assert.
      (role @self (spatial ?applicant co-located @self))
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?job ?jk {?job org ?org}
                     {?job job-id ?}
                     -{?job filled-by ?})
      (utility obligation always-pick)
      (effects (maintain-proposal {@self HIRE ?applicant ?jk}
                 [/postlude (begin-belief {?job filled-by ?applicant})])))

    ; THE WORD: the seat of his kind is held - by him, and he is told it is his; by
    ; another and no seat of his kind stands open, and he is told who holds it. One rung,
    ; because the two are one situation with two answers: a filled seat of his kind. The
    ; seat is named by DESCRIPTION - a job has no name; the org and the line make it
    ; THAT seat - and the message QUOTES, so the (o ..) resolves in HIS mind.
    (try
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?job ?jk {?job org ?org}
                     {?job filled-by ?holder})
      (utility obligation always-pick)
      (effects
        (any {?job job-id ?}).target: ?line
        (cond
          (case (= ?holder ?applicant)
            (utterable-msg {(o ?jk {@o org ?org} {@o job-id ?line}) filled-by @you}): ?msg
            (if (and ?msg -{@self SAY ?msg ?applicant})
                (then (maintain-proposal {@self SAY ?msg ?applicant})))
            (if {@self SAY ?msg ?applicant /succ}
                (then (set-outcome ?ha-rel /succ))))
          (case (unsubstantial (open-job-for ?org ?jk))
            (utterable-msg {(o ?jk {@o org ?org} {@o job-id ?line}) filled-by ?holder}): ?msg
            (if (and ?msg -{@self SAY ?msg ?applicant})
                (then (maintain-proposal {@self SAY ?msg ?applicant})))
            (if {@self SAY ?msg ?applicant /succ}
                (then (set-outcome ?ha-rel /fail)))))))))
