# Tickex: Decentralized Ticketing Solution

## Prerequisites

Ensure you have the following tools installed:
- [Docker](https://www.docker.com/get-started) for containerization.
- [MetaMask](https://metamask.io/) as a browser extension for interacting with the blockchain.
- [Visual Studio Code](https://code.visualstudio.com/) (recommended) as the integrated development environment.
- [Mutagen](https://mutagen.io/) (optional for Mac users) for file synchronization enhancement.

## Visual Studio Code Extensions

Install the following extensions for an optimized development experience in VS Code:
- **ElixirLS**: Provides Elixir support and inline feedback.
- **Solidity by Juan Blanco**: Offers Solidity language support for Ethereum smart contracts.
- **Docker**: Facilitates Docker integration and management.

## Mutagen Installation (Mac Users)

Mac users may install Mutagen for improved file synchronization:

```bash
brew install mutagen-io/mutagen/mutagen
```

## Using Mutagen (Optional)

To use Mutagen, create a `compose.override.yml` in the main directory with the following content:

```yaml
version: '3.8'

services:
  app:
    volumes:
      - code-sync:/app:delegated

volumes:
  code-sync:

x-mutagen:
  sync:
    app-code:
      alpha: "./app"
      beta: "volume://code-sync"
      mode: "two-way-resolved"
      ignore:
        vcs: true
```

Use `mutagen-compose up` instead of `docker-compose up`.

## Setting Up .env File

Copy the `.env.example` file and rename it to `.env`:

```bash
cp app/.env.example app/.env
```

## MetaMask Setup

1. Install MetaMask as a browser extension.
2. Add your local network with the RPC URL `http://0.0.0.0:8545/` and Chain ID `1337`.
3. Import the accounts displayed in the Hardhat logs into MetaMask to have test Ether for transactions.

## Starting the Project

Execute the following command to start the Docker containers:

```bash
docker-compose up
```

To run commands inside the containers, use:

```bash
docker-compose exec [service_name] bash
```

For example, use `docker-compose exec app bash` for the app container.

## Deploy the Contracts

To deploy the contracts, follow these steps:

### Compile Contracts

First, compile the contracts:
```bash
npm run compile
```

### Deploying Locally

To deploy the contracts on a local network:
```bash
npx hardhat run scripts/deploy.ts --network hardhat
```
Run this command inside the `chain` container.

### Deploying to Mumbai Testnet

To deploy the contracts to the Mumbai Testnet, follow these steps:

1. **Set Up Environment Variables**:
   - Copy the `.env.example` file to `.env`:
     ```bash
     cp chain/.env.example chain/.env
     ```
   - Edit the `.env` file inside the `chain` folder to add your RPC URL and a private key:
     - Create a free RPC URL using [Infura](https://infura.io/) or [Alchemy](https://www.alchemy.com/).
     - Add a private key from a wallet of your choice. Ensure that this wallet has a small amount of MATIC for deployment.

2. **Deploy Contracts**:
   - Deploy the contracts to the Mumbai network:
     ```bash
     npx hardhat run scripts/deploy.ts --network mumbai
     ```
   - Note down the contract addresses output by the deployment script.

3. **Copy ABI JSON Files**:
   - Copy the `<ContractName>.json` files from `artifacts/contracts/<ContractName>.sol/` to the `app/priv/contracts` folder.
   - Create the `app/priv/contracts` folder if it doesn't exist.

4. **Generate Elixir Contract Modules**:
   - Inside the `app` container, run:
     ```bash
     mix import_abi
     ```
   - This command generates Elixir modules for each contract.

5. **Update Contract Addresses in Elixir Modules**:
   - Open each `<ContractName>.ex` file in the `app/lib/tickex/contracts/` folder.
   - Replace the placeholder text `<Fill in contract address>` with the actual contract addresses you noted earlier.

### Acquiring Test MATIC

- You need a small amount of MATIC for deploying the contracts on the Mumbai Testnet.
- Obtain free MATIC from faucets like [Polygon Mumbai Faucet](https://mumbaifaucet.com/).

## Useful Commands

- **Run Elixir tests** (in the `app` container):
  ```bash
  mix test
  ```

- **Execute Hardhat commands** (in the `chain` container):
  ```bash
  npx hardhat test
  ```
  ```bash
  npx hardhat run scripts/deploy.js
  ```