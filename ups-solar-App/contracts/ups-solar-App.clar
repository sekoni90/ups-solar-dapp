;; =========================================================
;; UPS SOLAR APP - MAIN CONTRACT
;; Integrated Service Marketplace Platform
;; =========================================================
;; Description: Main orchestration contract that integrates
;;              roles, escrow, and marketplace functionality
;;              for a complete service management platform
;; Version: 1.0.0
;; Author: UPS Solar Team
;; =========================================================

;; -------------------------
;; Constants
;; -------------------------

(define-constant contract-owner tx-sender)

;; Service Types
(define-constant SERVICE-UPS u1)
(define-constant SERVICE-SOLAR u2)
(define-constant SERVICE-ELECTRICAL u3)

;; Error Codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-EXISTS (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-NOT-COMPLETED (err u104))
(define-constant ERR-INSUFFICIENT-FUNDS (err u105))
(define-constant ERR-INVALID-SERVICE-TYPE (err u106))
(define-constant ERR-INVALID-STATUS (err u107))
(define-constant ERR-ORDER-ALREADY-COMPLETED (err u108))

;; -------------------------
;; Data Variables
;; -------------------------

(define-data-var contract-version (string-ascii 10) "1.0.0")
(define-data-var platform-fee-percentage uint u5) ;; 5% platform fee

;; -------------------------
;; Integrated Public Functions
;; -------------------------

;; @desc Creates order with automatic escrow funding
;; @param service-type: Type of service
;; @param amount: Service cost
;; @param description: Order description
;; @param installer: Assigned installer principal
;; @returns (response uint uint) - Returns order-id
(define-public (create-order-with-escrow 
  (service-type uint) 
  (amount uint) 
  (description (string-ascii 256))
  (installer principal))
  (let (
    (order-id-response (try! (contract-call? .service-marketplace create-order service-type amount description)))
  )
    (begin
      ;; Fund escrow for the order
      (try! (contract-call? .escrow fund-escrow order-id-response amount installer))
      
      ;; Assign installer
      (try! (contract-call? .service-marketplace assign-installer order-id-response installer))
      
      (ok order-id-response)
    )
  )
)

;; @desc Completes order and releases escrow payment
;; @param order-id: Unique identifier for the order
;; @returns (response bool uint)
(define-public (complete-order-and-release (order-id uint))
  (begin
    ;; Mark order as completed
    (try! (contract-call? .service-marketplace complete-order order-id))
    
    ;; Release escrow payment
    (try! (contract-call? .escrow release-escrow order-id))
    
    (ok true)
  )
)

;; -------------------------
;; Administrative Functions
;; -------------------------

;; @desc Updates platform fee percentage
;; @param new-fee: New fee percentage (0-100)
;; @returns (response bool uint)
(define-public (set-platform-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) ERR-NOT-AUTHORIZED)
    (asserts! (<= new-fee u100) ERR-INVALID-AMOUNT)
    (var-set platform-fee-percentage new-fee)
    (ok true)
  )
)

;; -------------------------
;; Read-Only Functions
;; -------------------------

;; @desc Gets contract version
;; @returns (string-ascii 10)
(define-read-only (get-version)
  (var-get contract-version)
)

;; @desc Gets platform fee percentage
;; @returns uint
(define-read-only (get-platform-fee)
  (var-get platform-fee-percentage)
)

;; @desc Calculates platform fee for an amount
;; @param amount: Amount to calculate fee for
;; @returns uint
(define-read-only (calculate-platform-fee (amount uint))
  (/ (* amount (var-get platform-fee-percentage)) u100)
)

;; @desc Gets contract owner
;; @returns principal
(define-read-only (get-contract-owner)
  contract-owner
)

;; @desc Gets comprehensive order status
;; @param order-id: Unique identifier for the order
;; @returns (optional order-status)
(define-read-only (get-order-status (order-id uint))
  (let (
    (order (contract-call? .service-marketplace get-order order-id))
    (escrow (contract-call? .escrow get-escrow order-id))
  )
    (some {
      order-details: order,
      escrow-details: escrow
    })
  )
)
