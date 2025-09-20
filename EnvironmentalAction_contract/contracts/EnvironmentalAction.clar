
;; title: EnvironmentalAction
;; version: 1.0.0
;; summary: A collaborative platform for climate policy adoption and carbon reduction strategies
;; description: This contract enables users to propose, vote on, and track environmental policies and carbon reduction initiatives

;; traits
;;

;; token definitions
;;

;; constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_PROPOSAL_NOT_FOUND (err u404))
(define-constant ERR_ALREADY_VOTED (err u409))
(define-constant ERR_VOTING_ENDED (err u410))
(define-constant ERR_INVALID_AMOUNT (err u400))

;; data vars
(define-data-var next-proposal-id uint u1)
(define-data-var total-carbon-credits uint u0)

;; data maps
(define-map proposals
  { proposal-id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    proposer: principal,
    votes-for: uint,
    votes-against: uint,
    carbon-impact: uint,
    end-block: uint,
    executed: bool
  }
)

(define-map votes
  { proposal-id: uint, voter: principal }
  { vote: bool }
)

(define-map user-carbon-credits
  { user: principal }
  { credits: uint }
)

(define-map carbon-reduction-projects
  { project-id: uint }
  {
    title: (string-ascii 100),
    creator: principal,
    carbon-saved: uint,
    verified: bool,
    credits-awarded: uint
  }
)

(define-data-var next-project-id uint u1)

;; public functions

;; Create a new environmental policy proposal
(define-public (create-proposal (title (string-ascii 100)) (description (string-ascii 500)) (carbon-impact uint) (voting-period uint))
  (let
    (
      (proposal-id (var-get next-proposal-id))
      (end-block (+ block-height voting-period))
    )
    (map-set proposals
      { proposal-id: proposal-id }
      {
        title: title,
        description: description,
        proposer: tx-sender,
        votes-for: u0,
        votes-against: u0,
        carbon-impact: carbon-impact,
        end-block: end-block,
        executed: false
      }
    )
    (var-set next-proposal-id (+ proposal-id u1))
    (ok proposal-id)
  )
)

;; Vote on a proposal
(define-public (vote-on-proposal (proposal-id uint) (vote-for bool))
  (let
    (
      (proposal (unwrap! (map-get? proposals { proposal-id: proposal-id }) ERR_PROPOSAL_NOT_FOUND))
      (existing-vote (map-get? votes { proposal-id: proposal-id, voter: tx-sender }))
    )
    (asserts! (is-none existing-vote) ERR_ALREADY_VOTED)
    (asserts! (<= block-height (get end-block proposal)) ERR_VOTING_ENDED)

    (map-set votes { proposal-id: proposal-id, voter: tx-sender } { vote: vote-for })

    (if vote-for
      (map-set proposals
        { proposal-id: proposal-id }
        (merge proposal { votes-for: (+ (get votes-for proposal) u1) })
      )
      (map-set proposals
        { proposal-id: proposal-id }
        (merge proposal { votes-against: (+ (get votes-against proposal) u1) })
      )
    )
    (ok true)
  )
)

;; Submit a carbon reduction project
(define-public (submit-carbon-project (title (string-ascii 100)) (carbon-saved uint))
  (let
    (
      (project-id (var-get next-project-id))
    )
    (asserts! (> carbon-saved u0) ERR_INVALID_AMOUNT)

    (map-set carbon-reduction-projects
      { project-id: project-id }
      {
        title: title,
        creator: tx-sender,
        carbon-saved: carbon-saved,
        verified: false,
        credits-awarded: u0
      }
    )
    (var-set next-project-id (+ project-id u1))
    (ok project-id)
  )
)

;; Verify and award credits for a carbon reduction project (only contract owner)
(define-public (verify-project (project-id uint) (credits-to-award uint))
  (let
    (
      (project (unwrap! (map-get? carbon-reduction-projects { project-id: project-id }) ERR_PROPOSAL_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)

    (map-set carbon-reduction-projects
      { project-id: project-id }
      (merge project { verified: true, credits-awarded: credits-to-award })
    )

    ;; Award credits to the project creator
    (let
      (
        (current-credits (default-to u0 (get credits (map-get? user-carbon-credits { user: (get creator project) }))))
      )
      (map-set user-carbon-credits
        { user: (get creator project) }
        { credits: (+ current-credits credits-to-award) }
      )
    )

    ;; Update total carbon credits
    (var-set total-carbon-credits (+ (var-get total-carbon-credits) credits-to-award))
    (ok true)
  )
)

;; Transfer carbon credits between users
(define-public (transfer-credits (recipient principal) (amount uint))
  (let
    (
      (sender-credits (default-to u0 (get credits (map-get? user-carbon-credits { user: tx-sender }))))
      (recipient-credits (default-to u0 (get credits (map-get? user-carbon-credits { user: recipient }))))
    )
    (asserts! (>= sender-credits amount) ERR_INVALID_AMOUNT)

    (map-set user-carbon-credits { user: tx-sender } { credits: (- sender-credits amount) })
    (map-set user-carbon-credits { user: recipient } { credits: (+ recipient-credits amount) })
    (ok true)
  )
)

;; read only functions

;; Get proposal details
(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals { proposal-id: proposal-id })
)

;; Get user's vote on a proposal
(define-read-only (get-user-vote (proposal-id uint) (user principal))
  (map-get? votes { proposal-id: proposal-id, voter: user })
)

;; Get user's carbon credits
(define-read-only (get-user-credits (user principal))
  (default-to u0 (get credits (map-get? user-carbon-credits { user: user })))
)

;; Get carbon reduction project details
(define-read-only (get-project (project-id uint))
  (map-get? carbon-reduction-projects { project-id: project-id })
)

;; Get total carbon credits in the system
(define-read-only (get-total-carbon-credits)
  (var-get total-carbon-credits)
)

;; Get next proposal ID
(define-read-only (get-next-proposal-id)
  (var-get next-proposal-id)
)

;; Get next project ID
(define-read-only (get-next-project-id)
  (var-get next-project-id)
)

;; Check if proposal voting has ended
(define-read-only (is-voting-ended (proposal-id uint))
  (match (map-get? proposals { proposal-id: proposal-id })
    proposal (> block-height (get end-block proposal))
    false
  )
)

;; Get proposal voting results
(define-read-only (get-voting-results (proposal-id uint))
  (match (map-get? proposals { proposal-id: proposal-id })
    proposal
    (some {
      votes-for: (get votes-for proposal),
      votes-against: (get votes-against proposal),
      total-votes: (+ (get votes-for proposal) (get votes-against proposal)),
      passed: (> (get votes-for proposal) (get votes-against proposal))
    })
    none
  )
)

;; private functions
;;
