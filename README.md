# Wedding Marketplace Smart Contract

This smart contract represents a wedding marketplace on the Sui blockchain. It provides functionality for managing vendors, customers, wedding packages, bookings, and customer reviews.

## Overview

The Wedding Marketplace smart contract enables users to:

- Create and manage vendors providing various wedding services.
- Create and manage customers with contact information.
- Define wedding packages, including pricing and details.
- Make bookings for specific wedding packages.
- Create customer reviews for vendors based on their services.

## Features

- **Vendor Management:**
  - Create a new vendor with name, description, contact details, and service type.
  - Update the vendor's name and other details.
  - Delete a vendor profile.

- **Customer Management:**
  - Create new customer profiles with name, email, and contact number.
  - Update customer information (e.g., name, email).
  - Delete a customer profile.

- **Wedding Packages:**
  - Create wedding packages with a name, price, and details.
  - Retrieve package information by ID.
  - Update package price or details.
  - Delete a wedding package.

- **Bookings:**
  - Create bookings for customers with a specified wedding date.
  - Update the booking status.
  - Retrieve booking information by ID.
  - Delete a booking.

- **Customer Reviews:**
  - Create customer reviews for vendors, including a rating (out of 10) and comments.
  - Update the review rating or comments.
  - Retrieve reviews by ID.
  - Delete a review.

## Dependencies

- The Wedding Marketplace smart contract is built on the Sui blockchain framework.
- Ensure you have the Move compiler installed and configured to the appropriate framework (e.g., `framework/devnet` or `framework/testnet`).

```bash
Sui = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "framework/devnet" }
```

## Installation and Deployment

To deploy and use the Wedding Marketplace smart contract, follow these steps:

1. **Move Compiler Installation:**
   Ensure the Move compiler is installed. Refer to the [Sui documentation](https://docs.sui.io/) for detailed installation instructions.

2. **Compile the Smart Contract:**
   Configure the Sui dependency to match your chosen framework (e.g., `framework/devnet`), then build the contract.

   ```bash
   sui move build
   ```

3. **Deployment:**
   Deploy the compiled smart contract to your chosen Sui blockchain network.

   ```bash
   sui client publish --gas-budget 100000000 --json
   ```
