# UPS Solar App - API Reference

## Table of Contents
- [Roles Contract](#roles-contract)
- [Escrow Contract](#escrow-contract)
- [Service Marketplace Contract](#service-marketplace-contract)
- [Main Contract](#main-contract)

---

## Roles Contract

### Public Functions

#### `add-installer`
Adds a new installer to the platform.

**Parameters:**
- `installer` (principal): Address of the installer to add

**Returns:** `(response bool uint)`

**Authorization:** Contract owner only

**Errors:**
- `ERR-NOT-AUTHORIZED (100)`: Caller is not contract owner
- `ERR-ALREADY-EXISTS (102)`: Installer already exists

**Example:**
```clarity
(contract-call? .roles add-installer 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

---

#### `remove-installer`
Removes an installer from the platform.

**Parameters:**
- `installer` (principal): Address of the installer to remove

**Returns:** `(response bool uint)`

**Authorization:** Contract owner only

**Errors:**
- `ERR-NOT-AUTHORIZED (100)`: Caller is not contract owner
- `ERR-NOT-FOUND (101)`: Installer not found

**Example:**
```clarity
(contract-call? .roles remove-installer 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

---

### Read-Only Functions

#### `is-installer`
Checks if a user is an authorized installer.

**Parameters:**
- `user` (principal): Address to check

**Returns:** `bool`

**Example:**
```clarity
(contract-call? .roles is-installer 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
;; Returns: true or false
```

---

#### `get-contract-owner`
Returns the contract owner address.

**Parameters:** None

**Returns:** `principal`

**Example:**
```clarity
(contract-call? .roles get-contract-owner)
```

---

#### `get-installer-metadata`
Retrieves metadata for an installer.

**Parameters:**
- `installer` (principal): Installer address

**Returns:** `(optional {added-at: uint, added-by: principal, active: bool})`

**Example:**
```clarity
(contract-call? .roles get-installer-metadata 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

---

#### `get-total-installers`
Returns the total number of active installers.

**Parameters:** None

**Returns:** `uint`

**Example:**
```clarity
(contract-call? .roles get-total-installers)
```

---

## Escrow Contract

### Public Functions

#### `fund-escrow`
Creates and funds an escrow for a service order.

**Parameters:**
- `order-id` (uint): Unique order identifier
- `amount` (uint): Amount in microSTX
- `recipient` (principal): Address to receive funds upon release

**Returns:** `(response bool uint)`

**Errors:**
- `ERR-INVALID-AMOUNT (103)`: Amount is zero
- `ERR-ALREADY-EXISTS (102)`: Escrow already exists for this order

**Example:**
```clarity
(contract-call? .escrow fund-escrow u1 u5000000 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

---

#### `release-escrow`
Releases escrowed funds to the recipient.

**Parameters:**
- `order-id` (uint): Unique order identifier

**Returns:** `(response bool uint)`

**Authorization:** Authorized installer only

**Errors:**
- `ERR-NOT-AUTHORIZED (100)`: Caller is not authorized installer
- `ERR-NOT-FOUND (101)`: Escrow not found
- `ERR-ALREADY-RELEASED (104)`: Escrow already released

**Example:**
```clarity
(contract-call? .escrow release-escrow u1)
```

---

#### `refund-escrow`
Refunds escrowed funds back to the payer.

**Parameters:**
- `order-id` (uint): Unique order identifier

**Returns:** `(response bool uint)`

**Authorization:** Payer or authorized installer

**Errors:**
- `ERR-NOT-AUTHORIZED (100)`: Caller not authorized
- `ERR-NOT-FOUND (101)`: Escrow not found
- `ERR-ALREADY-RELEASED (104)`: Escrow already released

**Example:**
```clarity
(contract-call? .escrow refund-escrow u1)
```

---

### Read-Only Functions

#### `get-escrow`
Retrieves escrow details.

**Parameters:**
- `order-id` (uint): Order identifier

**Returns:** `(optional {payer: principal, recipient: principal, amount: uint, released: bool, created-at: uint, released-at: (optional uint)})`

**Example:**
```clarity
(contract-call? .escrow get-escrow u1)
```

---

#### `is-escrow-active`
Checks if an escrow is active (not released).

**Parameters:**
- `order-id` (uint): Order identifier

**Returns:** `bool`

**Example:**
```clarity
(contract-call? .escrow is-escrow-active u1)
```

---

#### `get-total-escrowed`
Returns total amount currently in escrow.

**Parameters:** None

**Returns:** `uint`

---

#### `get-total-released`
Returns total amount released from escrow.

**Parameters:** None

**Returns:** `uint`

---

#### `get-contract-balance`
Returns the contract's STX balance.

**Parameters:** None

**Returns:** `uint`

---

## Service Marketplace Contract

### Public Functions

#### `create-order`
Creates a new service order.

**Parameters:**
- `service-type` (uint): Service type (1=UPS, 2=Solar, 3=Electrical)
- `amount` (uint): Service cost in microSTX
- `description` (string-ascii 256): Order description

**Returns:** `(response uint uint)` - Returns order ID

**Errors:**
- `ERR-INVALID-AMOUNT (103)`: Amount is zero
- `ERR-INVALID-SERVICE-TYPE (106)`: Invalid service type

**Example:**
```clarity
(contract-call? .service-marketplace create-order u1 u5000000 "Install UPS system")
```

---

#### `assign-installer`
Assigns an installer to an order.

**Parameters:**
- `order-id` (uint): Order identifier
- `installer` (principal): Installer address

**Returns:** `(response bool uint)`

**Errors:**
- `ERR-NOT-AUTHORIZED (100)`: Installer not authorized
- `ERR-NOT-FOUND (101)`: Order not found
- `ERR-INVALID-STATUS (107)`: Order not in pending status

**Example:**
```clarity
(contract-call? .service-marketplace assign-installer u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

---

#### `start-order`
Updates order status to in-progress.

**Parameters:**
- `order-id` (uint): Order identifier

**Returns:** `(response bool uint)`

**Authorization:** Assigned installer only

**Errors:**
- `ERR-NOT-AUTHORIZED (100)`: Caller is not assigned installer
- `ERR-NOT-FOUND (101)`: Order not found
- `ERR-INVALID-STATUS (107)`: Order not in assigned status

**Example:**
```clarity
(contract-call? .service-marketplace start-order u1)
```

---

#### `complete-order`
Marks an order as completed.

**Parameters:**
- `order-id` (uint): Order identifier

**Returns:** `(response bool uint)`

**Authorization:** Assigned installer only

**Errors:**
- `ERR-NOT-AUTHORIZED (100)`: Caller is not assigned installer
- `ERR-NOT-FOUND (101)`: Order not found
- `ERR-INVALID-STATUS (107)`: Order not in progress

**Example:**
```clarity
(contract-call? .service-marketplace complete-order u1)
```

---

#### `cancel-order`
Cancels an order.

**Parameters:**
- `order-id` (uint): Order identifier

**Returns:** `(response bool uint)`

**Authorization:** Customer only

**Errors:**
- `ERR-NOT-AUTHORIZED (100)`: Caller is not customer
- `ERR-NOT-FOUND (101)`: Order not found
- `ERR-ORDER-ALREADY-COMPLETED (108)`: Cannot cancel completed order

**Example:**
```clarity
(contract-call? .service-marketplace cancel-order u1)
```

---

### Read-Only Functions

#### `get-order`
Retrieves order details.

**Parameters:**
- `order-id` (uint): Order identifier

**Returns:** `(optional order-data)`

**Example:**
```clarity
(contract-call? .service-marketplace get-order u1)
```

---

#### `get-customer-orders`
Gets all orders for a customer.

**Parameters:**
- `customer` (principal): Customer address

**Returns:** `(optional (list 100 uint))`

**Example:**
```clarity
(contract-call? .service-marketplace get-customer-orders 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

---

#### `get-installer-orders`
Gets all orders for an installer.

**Parameters:**
- `installer` (principal): Installer address

**Returns:** `(optional (list 100 uint))`

**Example:**
```clarity
(contract-call? .service-marketplace get-installer-orders 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

---

#### `get-total-orders`
Returns total number of orders.

**Parameters:** None

**Returns:** `uint`

---

#### `get-total-completed`
Returns total number of completed orders.

**Parameters:** None

**Returns:** `uint`

---

#### `get-order-counter`
Returns current order counter.

**Parameters:** None

**Returns:** `uint`

---

#### `get-service-name`
Gets service type name.

**Parameters:**
- `service-type` (uint): Service type code

**Returns:** `(string-ascii 20)`

**Example:**
```clarity
(contract-call? .service-marketplace get-service-name u1)
;; Returns: "UPS Installation"
```

---

## Main Contract

### Public Functions

#### `create-order-with-escrow`
Creates order with automatic escrow funding (integrated workflow).

**Parameters:**
- `service-type` (uint): Service type
- `amount` (uint): Service cost
- `description` (string-ascii 256): Order description
- `installer` (principal): Assigned installer

**Returns:** `(response uint uint)` - Returns order ID

**Example:**
```clarity
(contract-call? .ups-solar-App create-order-with-escrow 
  u1 
  u5000000 
  "Complete UPS installation" 
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

---

#### `complete-order-and-release`
Completes order and releases escrow payment (integrated workflow).

**Parameters:**
- `order-id` (uint): Order identifier

**Returns:** `(response bool uint)`

**Example:**
```clarity
(contract-call? .ups-solar-App complete-order-and-release u1)
```

---

#### `set-platform-fee`
Updates platform fee percentage.

**Parameters:**
- `new-fee` (uint): New fee percentage (0-100)

**Returns:** `(response bool uint)`

**Authorization:** Contract owner only

**Example:**
```clarity
(contract-call? .ups-solar-App set-platform-fee u10)
```

---

### Read-Only Functions

#### `get-version`
Returns contract version.

**Parameters:** None

**Returns:** `(string-ascii 10)`

---

#### `get-platform-fee`
Returns platform fee percentage.

**Parameters:** None

**Returns:** `uint`

---

#### `calculate-platform-fee`
Calculates platform fee for an amount.

**Parameters:**
- `amount` (uint): Amount to calculate fee for

**Returns:** `uint`

**Example:**
```clarity
(contract-call? .ups-solar-App calculate-platform-fee u1000000)
;; Returns: u50000 (5% of 1 STX)
```

---

#### `get-contract-owner`
Returns contract owner address.

**Parameters:** None

**Returns:** `principal`

---

#### `get-order-status`
Gets comprehensive order status including escrow details.

**Parameters:**
- `order-id` (uint): Order identifier

**Returns:** `(optional {order-details: ..., escrow-details: ...})`

**Example:**
```clarity
(contract-call? .ups-solar-App get-order-status u1)
```

---

## Common Patterns

### Complete Order Workflow

```clarity
;; 1. Add installer (admin)
(contract-call? .roles add-installer 'INSTALLER-ADDRESS)

;; 2. Create order (customer)
(contract-call? .service-marketplace create-order u1 u5000000 "Order description")

;; 3. Fund escrow (customer)
(contract-call? .escrow fund-escrow u1 u5000000 'INSTALLER-ADDRESS)

;; 4. Assign installer (admin)
(contract-call? .service-marketplace assign-installer u1 'INSTALLER-ADDRESS)

;; 5. Start work (installer)
(contract-call? .service-marketplace start-order u1)

;; 6. Complete work (installer)
(contract-call? .service-marketplace complete-order u1)

;; 7. Release payment (installer)
(contract-call? .escrow release-escrow u1)
```

### Integrated Workflow (Simplified)

```clarity
;; 1. Add installer (admin)
(contract-call? .roles add-installer 'INSTALLER-ADDRESS)

;; 2. Create order with escrow (customer)
(contract-call? .ups-solar-App create-order-with-escrow 
  u1 u5000000 "Order description" 'INSTALLER-ADDRESS)

;; 3. Start work (installer)
(contract-call? .service-marketplace start-order u1)

;; 4. Complete and release (installer)
(contract-call? .ups-solar-App complete-order-and-release u1)
```
