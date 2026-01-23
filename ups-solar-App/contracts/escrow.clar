;; =========================================================
;; escrow.clar
;; Holds and releases payments
;; =========================================================

(use-trait roles-trait .roles)

(define-map escrows
  uint
  {
    payer: principal,
    amount: uint,
    released: bool
  }
)

;; -------------------------
;; Fund Escrow
;; -------------------------

(define-public (fund-escrow (order-id uint) (amount uint))
  (begin
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set escrows order-id {
      payer: tx-sender,
      amount: amount,
      released: false
    })
    (ok true)
  )
)

;; -------------------------
;; Release Escrow
;; -------------------------

(define-public (release-escrow (order-id uint) (recipient principal))
  (match (map-get? escrows order-id)
    escrow
    (begin
      (asserts!
        (contract-call? .roles is-installer tx-sender)
        ERR-NOT-AUTHORIZED
      )
      (asserts! (is-eq escrow.released false) ERR-NOT-COMPLETED)
      (try! (stx-transfer? escrow.amount (as-contract tx-sender) recipient))
      (map-set escrows order-id (merge escrow { released: true }))
      (ok true)
    )
    ERR-NOT-FOUND
  )
)

;; -------------------------
;; Read-only
;; -------------------------

(define-read-only (get-escrow (order-id uint))
  (map-get? escrows order-id)
)
