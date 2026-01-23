;; =========================================================
;; ESCROW CONTRACT
;; Secure Payment Holding and Release System
;; =========================================================
;; Description: Manages escrow payments for service orders,
;;              ensuring secure fund transfers between customers
;;              and service providers
;; Version: 1.0.0
;; =========================================================

;; -------------------------
;; Constants
;; -------------------------

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-EXISTS (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-ALREADY-RELEASED (err u104))
(define-constant ERR-INSUFFICIENT-FUNDS (err u105))

;; -------------------------
;; Data Maps
;; -------------------------

(define-map escrows
  uint
  {
    payer: principal,
    recipient: principal,
    amount: uint,
    released: bool,
    created-at: uint,
    released-at: (optional uint)
  }
)

;; -------------------------
;; Data Variables
;; -------------------------

(define-data-var total-escrowed uint u0)
(define-data-var total-released uint u0)

;; -------------------------
;; Public Functions
;; -------------------------

;; @desc Creates and funds an escrow for a service order
;; @param order-id: Unique identifier for the order
;; @param amount: Amount in microSTX to escrow
;; @param recipient: Principal who will receive funds upon release
;; @returns (response bool uint)
(define-public (fund-escrow (order-id uint) (amount uint) (recipient principal))
  (begin
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (is-none (map-get? escrows order-id)) ERR-ALREADY-EXISTS)
    
    ;; Transfer funds to contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    ;; Store escrow details
    (map-set escrows order-id {
      payer: tx-sender,
      recipient: recipient,
      amount: amount,
      released: false,
      created-at: block-height,
      released-at: none
    })
    
    (var-set total-escrowed (+ (var-get total-escrowed) amount))
    (ok true)
  )
)

;; @desc Releases escrowed funds to the recipient
;; @param order-id: Unique identifier for the order
;; @returns (response bool uint)
(define-public (release-escrow (order-id uint))
  (let (
    (escrow-data (unwrap! (map-get? escrows order-id) ERR-NOT-FOUND))
  )
    (begin
      ;; Verify caller is authorized installer
      (asserts! 
        (contract-call? .roles is-installer tx-sender) 
        ERR-NOT-AUTHORIZED
      )
      
      ;; Verify escrow hasn't been released
      (asserts! (not (get released escrow-data)) ERR-ALREADY-RELEASED)
      
      ;; Transfer funds to recipient
      (try! (as-contract (stx-transfer? 
        (get amount escrow-data)
        tx-sender
        (get recipient escrow-data)
      )))
      
      ;; Update escrow status
      (map-set escrows order-id (merge escrow-data { 
        released: true,
        released-at: (some block-height)
      }))
      
      (var-set total-released (+ (var-get total-released) (get amount escrow-data)))
      (ok true)
    )
  )
)

;; @desc Refunds escrowed funds back to the payer (emergency function)
;; @param order-id: Unique identifier for the order
;; @returns (response bool uint)
(define-public (refund-escrow (order-id uint))
  (let (
    (escrow-data (unwrap! (map-get? escrows order-id) ERR-NOT-FOUND))
  )
    (begin
      ;; Only payer or installer can initiate refund
      (asserts! 
        (or 
          (is-eq tx-sender (get payer escrow-data))
          (contract-call? .roles is-installer tx-sender)
        )
        ERR-NOT-AUTHORIZED
      )
      
      ;; Verify escrow hasn't been released
      (asserts! (not (get released escrow-data)) ERR-ALREADY-RELEASED)
      
      ;; Refund to payer
      (try! (as-contract (stx-transfer? 
        (get amount escrow-data)
        tx-sender
        (get payer escrow-data)
      )))
      
      ;; Mark as released to prevent double-spending
      (map-set escrows order-id (merge escrow-data { 
        released: true,
        released-at: (some block-height)
      }))
      
      (ok true)
    )
  )
)

;; -------------------------
;; Read-Only Functions
;; -------------------------

;; @desc Gets escrow details for an order
;; @param order-id: Unique identifier for the order
;; @returns (optional escrow-data)
(define-read-only (get-escrow (order-id uint))
  (map-get? escrows order-id)
)

;; @desc Checks if an escrow exists and is active
;; @param order-id: Unique identifier for the order
;; @returns bool
(define-read-only (is-escrow-active (order-id uint))
  (match (map-get? escrows order-id)
    escrow (not (get released escrow))
    false
  )
)

;; @desc Gets total amount currently in escrow
;; @returns uint
(define-read-only (get-total-escrowed)
  (var-get total-escrowed)
)

;; @desc Gets total amount released from escrow
;; @returns uint
(define-read-only (get-total-released)
  (var-get total-released)
)

;; @desc Gets contract balance
;; @returns uint
(define-read-only (get-contract-balance)
  (stx-get-balance (as-contract tx-sender))
)
