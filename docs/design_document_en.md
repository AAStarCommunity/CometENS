# CometENS Design Document

## 1. Product Design

### 1.1. Core Vision

CometENS aims to be an open-source, decentralized framework for ENS (Ethereum Name Service) subdomain distribution and management. It enables any organization or individual owning a root domain (e.g., `aastar.eth`) to easily distribute second or third-level subdomains (e.g., `alice.aastar.eth` or `bob.paymaster.aastar.eth`) to their community members or users, empowering these subdomains with practical application value.

### 1.2. Core Features

1.  **Subdomain as NFT**
    *   All subdomains distributed through CometENS will exist as NFTs (ERC-721).
    *   Users have full ownership and control over their domain NFTs, allowing for free transfer and trade.
    *   Provide a deterministic ENS NFT, owned by the user's wallet, for every registered AirAccount user.

2.  **Multi-Chain Address Resolution**
    *   Users can point their ENS domain to multiple blockchain addresses (e.g., Ethereum, Optimism, Arbitrum), managing all wallets with a single domain.

3.  **Decentralized Identity (DID) and Social Graph**
    *   Users can edit profiles associated with their ENS, including:
        *   Avatar
        *   Social Links (Twitter, GitHub, etc.)
        *   Soul-Bound Tokens (SBTs)
    *   Build a foundational layer for Web3 personal identity and social networking.

4.  **DAPI (Decentralized Service) Pointing**
    *   Use ENS domains as dynamic, unique pointers to decentralized services or APIs.
    *   **Example**: In the SuperPaymaster ecosystem, Gas Sponsor providers can use their third-level domain (`bob.paymaster.aastar.eth`) as the unique entry point for their service, enabling automatic discovery and permissionless participation.

### 1.3. Target Users

1.  **Web3 Projects/Communities**: Those looking to provide their members with branded, identity-bound subdomains to enhance community cohesion.
2.  **DApp Developers**: Those in need of a decentralized way to identify and call services, such as AAStar's SuperPaymaster and AirAccount.
3.  **General Web3 Users**: Individuals seeking a unified, portable decentralized identity to manage their multi-chain assets.

## 2. Technical Framework Analysis

### 2.1. Overall Architecture

CometENS inherits and extends the concepts from `unruggable-gateways`. Its core is to leverage the low cost and high efficiency of Layer 2 (Optimism) for handling numerous domain resolution and update operations, while anchoring final ownership and critical resolution information on Layer 1 (Ethereum) to ensure security and decentralization.

```mermaid
graph TD
    subgraph Layer 1 (Ethereum)
        A[ENS Registry] --> B{CometENS Resolver};
        B -- reads root domain ownership --> A;
        C[Gateway Verifier] -- verifies --> B;
    end

    subgraph Layer 2 (Optimism)
        D[Storage Contract] <--> E[ENS Manager];
        E -- manages --> F[Subdomain NFTs];
    end

    subgraph Off-chain
        G[CometENS Server] -- reads L2 data --> D;
        H[User/DApp] -- queries --> G;
    end

    B -- queries via gateway --> G;
    E -- is controlled by --> H;

    style A fill:#f9f,stroke:#333,stroke-width:2px
    style F fill:#bbf,stroke:#333,stroke-width:2px
```

### 2.2. Key Components

1.  **Smart Contracts (Solidity / Foundry)**
    *   **L1 Resolver (`OPResolver.sol`)**: Deployed on Ethereum Mainnet.
        *   Acts as a standard ENS resolver, responding to resolution requests from DApps.
        *   Queries the CometENS Server deployed on L2 through a trusted Gateway to get the latest resolution data.
        *   Includes a built-in `GatewayVerifier` mechanism to ensure data from L2 is verified and secure.
    *   **L2 Management Contract (`ENSManager.sol`)**: Deployed on Optimism.
        *   Handles the logic for subdomain registration, renewal, and ownership changes.
        *   Interacts with `StorageContract` to update domain records.
        *   Mints and manages the NFTs representing subdomain ownership.
    *   **L2 Storage Contract (`StorageContract.sol`)**: Deployed on Optimism.
        *   Stores a large volume of ENS records (addresses, text records, avatars, etc.) at a low cost.
        *   Serves as the data source for the CometENS Server.

2.  **Backend Service (TypeScript / Node.js)**
    *   **CometENS Server**:
        *   A service implementing the CCIP-Read (EIP-3668) protocol.
        *   Listens to events from the `StorageContract` on L2 to get real-time updates of ENS records.
        *   Responds to data query requests from the L1 Resolver and provides cryptographic proofs, allowing the L1 Resolver to verify the data.

3.  **Frontend (React / Next.js)**
    *   Streamlined and adapted from `ens-app-v3`.
    *   Provides a user interface for:
        *   Registering and managing subdomains.
        *   Editing ENS profiles (addresses, text records, etc.).
        *   Viewing and transferring their domain NFTs.

4.  **Historical Submodules (vendor/)**
    *   `comet-ens-contracts`, `CometENS-frontend`, and `CometENS-old` are historical versions or external references for the project.
    *   They provide context and ideas for the project's evolution but are not directly involved in the current technical framework. They are mainly used for analysis and to draw inspiration from their design.

### 2.3. Technology Stack

*   **Smart Contracts**: Solidity + Foundry, leveraging its efficient testing and deployment framework.
*   **Backend**: TypeScript, Node.js, Ethers.js to build the CCIP-Read service.
*   **Frontend**: React/Next.js, re-developed based on the mature ENS frontend.
*   **Cross-Chain Communication**: Adopts the Unruggable Gateways concept, enabling secure L1 reads of L2 data via an off-chain service and an on-chain verifier, which is a lightweight cross-chain solution.
*   **Development & Test Chains**: Sepolia (L1) and OP Sepolia (L2).
*   **Mainnet Target**: Optimism Mainnet, with plans to expand to other L2s.
