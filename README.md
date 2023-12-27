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
cp .env.example .env
```

## MetaMask Setup

1. Install MetaMask as a browser extension.
2. Add your local network with the RPC URL `http://0.0.0.0:8545/` and Chain ID `80001`.
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