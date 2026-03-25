;; =========================================================
;; SERVICE MARKETPLACE CONTRACT
;; Order Management System
;; =========================================================
;; Description: Manages service orders for UPS, Solar, and
;;              Electrical installations with full lifecycle
;;              tracking and installer assignment
;; Version: 1.0.0
;; =========================================================

;; -------------------------
;; Constants
;; -------------------------

;; Service types
(define-constant SERVICE-UPS u1)
(define-constant SERVICE-SOLAR u2)
(define-constant SERVICE-ELECTRICAL u3)

;; Order status
(define-constant STATUS-PENDING u0)
(define-constant STATUS-ASSIGNED u1)
(define-constant STATUS-IN-PROGRESS u2)
(define-constant STATUS-COMPLETED u3)
(define-constant STATUS-CANCELLED u4)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-INVALID-SERVICE-TYPE (err u106))
(define-constant ERR-INVALID-STATUS (err u107))
(define-constant ERR-ORDER-ALREADY-COMPLETED (err u108))

;; -------------------------
;; Data Maps
;; -------------------------

(define-map orders
  uint
  {
    customer: principal,
    installer: (optional principal),
    service-type: uint,
    amount: uint,
    status: uint,
    created-at: uint,
    assigned-at: (optional uint),
    completed-at: (optional uint),
    description: (string-ascii 256)
  }
)

(define-map customer-orders principal (list 100 uint))
(define-map installer-orders principal (list 100 uint))

;; -------------------------
;; Data Variables
;; -------------------------

(define-data-var order-counter uint u0)
(define-data-var total-orders uint u0)
(define-data-var total-completed uint u0)

;; -------------------------
;; Public Functions
;; -------------------------

;; @desc Creates a new service order
;; @param service-type: Type of service (1=UPS, 2=Solar, 3=Electrical)
;; @param amount: Service cost in microSTX
;; @param description: Order description
;; @returns (response uint uint) - Returns order-id on success
(define-public (create-order (service-type uint) (amount uint) (description (string-ascii 256)))
  (let (
    (order-id (+ (var-get order-counter) u1))
  )
    (begin
      ;; Validate inputs
      (asserts! (> amount u0) ERR-INVALID-AMOUNT)
      (asserts! 
        (or 
          (is-eq service-type SERVICE-UPS)
          (is-eq service-type SERVICE-SOLAR)
          (is-eq service-type SERVICE-ELECTRICAL)
        )
        ERR-INVALID-SERVICE-TYPE
      )
      
      ;; Create order
      (map-set orders order-id {
        customer: tx-sender,
        installer: none,
        service-type: service-type,
        amount: amount,
        status: STATUS-PENDING,
        created-at: stacks-block-height,
        assigned-at: none,
        completed-at: none,
        description: description
      })
      
      ;; Update customer orders list
      (map-set customer-orders tx-sender 
        (unwrap-panic (as-max-len? 
          (append (default-to (list) (map-get? customer-orders tx-sender)) order-id)
          u100
        ))
      )
      
      ;; Update counters
      (var-set order-counter order-id)
      (var-set total-orders (+ (var-get total-orders) u1))
      
      (ok order-id)
    )
  )
)

;; @desc Assigns an installer to an order
;; @param order-id: Unique identifier for the order
;; @param installer: Principal of the installer
;; @returns (response bool uint)
(define-public (assign-installer (order-id uint) (installer principal))
  (let (
    (order-data (unwrap! (map-get? orders order-id) ERR-NOT-FOUND))
  )
    (begin
      ;; Verify installer is authorized
      (asserts! (contract-call? .roles is-installer installer) ERR-NOT-AUTHORIZED)
      
      ;; Verify order is in pending status
      (asserts! (is-eq (get status order-data) STATUS-PENDING) ERR-INVALID-STATUS)
      
      ;; Update order
      (map-set orders order-id (merge order-data {
        installer: (some installer),
        status: STATUS-ASSIGNED,
        assigned-at: (some stacks-block-height)
      }))
      
      ;; Update installer orders list
      (map-set installer-orders installer
        (unwrap-panic (as-max-len?
          (append (default-to (list) (map-get? installer-orders installer)) order-id)
          u100
        ))
      )
      
      (ok true)
    )
  )
)

;; @desc Updates order status to in-progress
;; @param order-id: Unique identifier for the order
;; @returns (response bool uint)
(define-public (start-order (order-id uint))
  (let (
    (order-data (unwrap! (map-get? orders order-id) ERR-NOT-FOUND))
  )
    (begin
      ;; Verify caller is assigned installer
      (asserts! 
        (is-eq (some tx-sender) (get installer order-data))
        ERR-NOT-AUTHORIZED
      )
      
      ;; Verify order is assigned
      (asserts! (is-eq (get status order-data) STATUS-ASSIGNED) ERR-INVALID-STATUS)
      
      ;; Update status
      (map-set orders order-id (merge order-data {
        status: STATUS-IN-PROGRESS
      }))
      
      (ok true)
    )
  )
)

;; @desc Marks an order as completed
;; @param order-id: Unique identifier for the order
;; @returns (response bool uint)
(define-public (complete-order (order-id uint))
  (let (
    (order-data (unwrap! (map-get? orders order-id) ERR-NOT-FOUND))
  )
    (begin
      ;; Verify caller is assigned installer
      (asserts! 
        (is-eq (some tx-sender) (get installer order-data))
        ERR-NOT-AUTHORIZED
      )
      
      ;; Verify order is in progress
      (asserts! (is-eq (get status order-data) STATUS-IN-PROGRESS) ERR-INVALID-STATUS)
      
      ;; Update order
      (map-set orders order-id (merge order-data {
        status: STATUS-COMPLETED,
        completed-at: (some stacks-block-height)
      }))
      
      (var-set total-completed (+ (var-get total-completed) u1))
      (ok true)
    )
  )
)

;; @desc Cancels an order (only by customer or contract owner)
;; @param order-id: Unique identifier for the order
;; @returns (response bool uint)
(define-public (cancel-order (order-id uint))
  (let (
    (order-data (unwrap! (map-get? orders order-id) ERR-NOT-FOUND))
  )
    (begin
      ;; Verify caller is customer
      (asserts! (is-eq tx-sender (get customer order-data)) ERR-NOT-AUTHORIZED)
      
      ;; Cannot cancel completed orders
      (asserts! (not (is-eq (get status order-data) STATUS-COMPLETED)) ERR-ORDER-ALREADY-COMPLETED)
      
      ;; Update status
      (map-set orders order-id (merge order-data {
        status: STATUS-CANCELLED
      }))
      
      (ok true)
    )
  )
)

;; -------------------------
;; Read-Only Functions
;; -------------------------

;; @desc Gets order details
;; @param order-id: Unique identifier for the order
;; @returns (optional order-data)
(define-read-only (get-order (order-id uint))
  (map-get? orders order-id)
)

;; @desc Gets all orders for a customer
;; @param customer: Principal of the customer
;; @returns (optional (list 100 uint))
(define-read-only (get-customer-orders (customer principal))
  (map-get? customer-orders customer)
)

;; @desc Gets all orders for an installer
;; @param installer: Principal of the installer
;; @returns (optional (list 100 uint))
(define-read-only (get-installer-orders (installer principal))
  (map-get? installer-orders installer)
)

;; @desc Gets total number of orders
;; @returns uint
(define-read-only (get-total-orders)
  (var-get total-orders)
)

;; @desc Gets total number of completed orders
;; @returns uint
(define-read-only (get-total-completed)
  (var-get total-completed)
)

;; @desc Gets current order counter
;; @returns uint
(define-read-only (get-order-counter)
  (var-get order-counter)
)

;; @desc Gets service type name
;; @param service-type: Service type code
;; @returns (string-ascii 20)
(define-read-only (get-service-name (service-type uint))
  (if (is-eq service-type SERVICE-UPS)
    "UPS Installation"
    (if (is-eq service-type SERVICE-SOLAR)
      "Solar Installation"
      (if (is-eq service-type SERVICE-ELECTRICAL)
        "Electrical Service"
        "Unknown Service"
      )
    )
  )
)
