![tickex](app/priv/static/images/tickex_color_light.svg)
# Tickex: Decentralized Ticketing Solution

Tickex is an innovative decentralized ticketing solution based on blockchain technology, specifically on the Polygon platform, and realized through smart contracts. This project aims to enhance security and transparency in the ticketing sector, emphasizing the development and evaluation of a functional prototype demonstrating the application and interaction of smart contracts within ticket sales.

## Getting Started

### Setting Up Environment Variables

1. Copy the `.env.example` file and rename it to `.env`:
    ```bash
    cp .env.example .env
    ```
   The `.env.example` file contains sample values for running the application. For development and deployment, specific values should be inserted into the `.env` file.

### MetaMask Setup

1. Install MetaMask as a browser extension.
2. Add the Mumbai Test Network to MetaMask with the following details:
   - RPC URL: `https://rpc-mumbai.maticvigil.com/`
   - Chain ID: `80001`
3. The currency used in this network is MATIC.

### Deploying Smart Contracts

1. **Compile Contracts**:
   First, compile the smart contracts using the command:
   ```bash
   npm run compile
   ```

2. **Deploying to the Mumbai Testnet**:
   - Set environment variables in the `.env` file with your RPC URL and private key.
   - Deploy the contracts using:
     ```bash
     npx hardhat run scripts/deploy.ts --network mumbai
     ```
   - Note down the contract addresses output by the deployment script.

3. **Updating Contract Addresses**:
   - Insert the noted contract addresses into the `.env` file.

### Acquiring Test MATIC

- To perform transactions on the Mumbai Testnet, you need a small amount of MATIC.
- Obtain free MATIC from faucets like [Polygon Mumbai Faucet](https://mumbaifaucet.com/).

## Running the Application

- After setting up the environment and deploying the contracts, you can start the application using Docker:
  ```bash
  docker-compose up
  ```
