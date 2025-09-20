# EnvironmentalAction

A collaborative platform for climate policy adoption and carbon reduction strategies built on the Stacks blockchain using Clarity smart contracts.

## Overview

EnvironmentalAction enables users to propose, vote on, and track environmental policies and carbon reduction initiatives. The platform features a democratic voting system for environmental proposals and a carbon credit system that rewards users for verified carbon reduction projects.

## Features

- **Environmental Policy Proposals**: Create and vote on climate policy initiatives
- **Democratic Voting System**: Community-driven decision making with time-bound voting periods
- **Carbon Credit System**: Earn and transfer carbon credits for verified environmental projects
- **Project Verification**: Administrator-controlled verification process for carbon reduction projects
- **Transparent Tracking**: Full visibility into voting results and carbon impact metrics

## Technical Specifications

- **Blockchain**: Stacks
- **Language**: Clarity 2.0
- **Contract Version**: 1.0.0
- **Epoch**: 2.5
- **Testing Framework**: Vitest with Clarinet SDK

## Project Structure

```
EnvironmentalAction/
├── EnvironmentalAction_contract/
│   ├── contracts/
│   │   └── EnvironmentalAction.clar    # Main smart contract
│   ├── tests/
│   │   └── EnvironmentalAction.test.ts # Contract tests
│   ├── settings/                       # Network configurations
│   │   ├── Devnet.toml
│   │   ├── Testnet.toml
│   │   └── Mainnet.toml
│   ├── Clarinet.toml                   # Project configuration
│   ├── package.json                    # Dependencies and scripts
│   └── vitest.config.js               # Test configuration
└── README.md
```

## Installation

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- [Node.js](https://nodejs.org/) (v16 or higher)
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd EnvironmentalAction
```

2. Navigate to the contract directory:
```bash
cd EnvironmentalAction_contract
```

3. Install dependencies:
```bash
npm install
```

4. Run tests to verify setup:
```bash
npm test
```

## Usage Examples

### Creating an Environmental Proposal

```clarity
;; Create a proposal for renewable energy adoption
(contract-call? .EnvironmentalAction create-proposal
  "Renewable Energy Initiative"
  "Proposal to incentivize solar panel installation in residential areas"
  u1000  ;; Expected carbon impact reduction (in tons)
  u144   ;; Voting period (in blocks, ~24 hours)
)
```

### Voting on a Proposal

```clarity
;; Vote in favor of proposal ID 1
(contract-call? .EnvironmentalAction vote-on-proposal u1 true)

;; Vote against proposal ID 1
(contract-call? .EnvironmentalAction vote-on-proposal u1 false)
```

### Submitting a Carbon Reduction Project

```clarity
;; Submit a carbon reduction project
(contract-call? .EnvironmentalAction submit-carbon-project
  "Community Tree Planting"
  u500  ;; Carbon saved in tons
)
```

### Transferring Carbon Credits

```clarity
;; Transfer 100 carbon credits to another user
(contract-call? .EnvironmentalAction transfer-credits
  'SP1HTBVD3JG9C05J7HBJTHGR0GGW7KX7X7F7DF5GV  ;; recipient
  u100  ;; amount
)
```

## Contract Functions Documentation

### Public Functions

#### `create-proposal`
Creates a new environmental policy proposal.

**Parameters:**
- `title` (string-ascii 100): Proposal title
- `description` (string-ascii 500): Detailed description
- `carbon-impact` (uint): Expected carbon reduction impact
- `voting-period` (uint): Duration of voting in blocks

**Returns:** `(response uint uint)` - Proposal ID on success

#### `vote-on-proposal`
Allows users to vote on an active proposal.

**Parameters:**
- `proposal-id` (uint): ID of the proposal to vote on
- `vote-for` (bool): True for yes, false for no

**Returns:** `(response bool uint)` - Success status

#### `submit-carbon-project`
Submits a carbon reduction project for verification.

**Parameters:**
- `title` (string-ascii 100): Project title
- `carbon-saved` (uint): Amount of carbon saved

**Returns:** `(response uint uint)` - Project ID on success

#### `verify-project`
Verifies a carbon project and awards credits (owner only).

**Parameters:**
- `project-id` (uint): ID of the project to verify
- `credits-to-award` (uint): Number of credits to award

**Returns:** `(response bool uint)` - Success status

#### `transfer-credits`
Transfers carbon credits between users.

**Parameters:**
- `recipient` (principal): Address of the recipient
- `amount` (uint): Number of credits to transfer

**Returns:** `(response bool uint)` - Success status

### Read-Only Functions

#### `get-proposal`
Retrieves proposal details by ID.

#### `get-user-vote`
Gets a user's vote on a specific proposal.

#### `get-user-credits`
Returns the carbon credit balance for a user.

#### `get-project`
Retrieves carbon reduction project details.

#### `get-total-carbon-credits`
Returns the total carbon credits in the system.

#### `get-voting-results`
Gets comprehensive voting results for a proposal.

#### `is-voting-ended`
Checks if voting period has ended for a proposal.

## Development

### Running Tests

```bash
# Run all tests
npm test

# Run tests with coverage and cost analysis
npm run test:report

# Watch mode for continuous testing
npm run test:watch
```

### Local Development

```bash
# Start Clarinet console
clarinet console

# Check contract syntax
clarinet check

# Run contract in REPL
clarinet console
```

## Deployment Guide

### Devnet Deployment

1. Configure your devnet settings in `settings/Devnet.toml`
2. Deploy using Clarinet:

```bash
clarinet deploy --devnet
```

### Testnet Deployment

1. Update `settings/Testnet.toml` with your deployment parameters
2. Ensure you have testnet STX for deployment
3. Deploy to testnet:

```bash
clarinet deploy --testnet
```

### Mainnet Deployment

1. Configure production settings in `settings/Mainnet.toml`
2. Ensure sufficient STX balance for deployment costs
3. Deploy to mainnet:

```bash
clarinet deploy --mainnet
```

## Security Notes

### Access Controls
- Only the contract owner can verify carbon reduction projects
- Users can only vote once per proposal
- Voting is time-bound to prevent manipulation

### Validation
- All user inputs are validated for proper types and ranges
- Carbon credit transfers check for sufficient balance
- Proposals require valid voting periods

### Best Practices
- Always verify project authenticity before awarding credits
- Monitor voting patterns for potential gaming
- Regularly audit carbon credit distribution
- Implement additional verification mechanisms for large projects

### Error Codes
- `u400`: Invalid amount or parameter
- `u401`: Not authorized (insufficient permissions)
- `u404`: Proposal or project not found
- `u409`: Already voted (duplicate vote attempt)
- `u410`: Voting period has ended

## Data Models

### Proposal Structure
```clarity
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
```

### Carbon Project Structure
```clarity
{
  title: (string-ascii 100),
  creator: principal,
  carbon-saved: uint,
  verified: bool,
  credits-awarded: uint
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the ISC License.

## Support

For questions, issues, or contributions, please open an issue in the repository or contact the development team.