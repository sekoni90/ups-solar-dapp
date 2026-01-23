;; =========================================================
;; service-marketplace.clar
;; Handles service orders
;; =========================================================

(use-trait roles-trait .roles)

(define-data-var order-counter uint u0)

(define-map orders
  uint
  {
    customer: principal,
    service-type: uint,
    amount: uint,
    completed: bool
  }
)

;; -------------------------
;; Create Service Order
;; -------------------------

(define-public (create-order (service-type uint) (amount uint))
  (begin
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (let ((order-id (+ (var-get order-counter) u1)))
      (begin
        (var-set order-counter order-id)
        (map-set orders order-id {
          customer: tx-sender,
          service-type: service-type,
          amount: amount,
          completed: false
        })
        (ok order-id)
      )
    )
  )
)

;; -------------------------
;; Mark Order Completed
;; -------------------------

(define-public (complete-order (order-id uint))
  (match (map-get? orders order-id)
    order
    (begin
      (asserts!
        (contract-call? .roles is-installer tx-sender)
        ERR-NOT-AUTHORIZED
      )
      (map-set orders order-id (merge order { completed: true }))
      (ok true)
    )
    ERR-NOT-FOUND
  )
)

;; -------------------------
;; Read-only
;; -------------------------

(define-read-only (get-order (order-id uint))
  (map-get? orders order-id)
)
