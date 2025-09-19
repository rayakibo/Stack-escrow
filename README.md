StackEscrow Smart Contract

A **Clarity-based escrow system** on the Stacks blockchain that enables secure, trustless transactions between parties without the need for intermediaries. StackEscrow ensures that funds are only released when both parties meet predefined conditions, reducing counterparty risk.

---

Features

- **Escrow Creation**: Lock STX or SIP-010 tokens in a secure escrow.
- **Dual Confirmation**: Funds are released when both buyer and seller agree.
- **Time-Locked Refunds**: Automatically refund funds if conditions are unmet.
- **Dispute Handling**: Supports conditional releases or refunds.
- **Transparency**: On-chain logic ensures fair and auditable execution.

---

Contract Structure

- `create-escrow` → Initialize a new escrow with locked funds.  
- `release-escrow` → Release funds to the recipient when conditions are satisfied.  
- `refund-escrow` → Refund funds to the sender if escrow is cancelled or expired.  
- `get-escrow` → View details of an escrow by ID.  

---

Deployment

1. Install [Clarinet](https://github.com/hirosystems/clarinet).
2. Clone this repository:
   ```bash
   git clone https://github.com/your-username/stack-escrow.git
   cd stack-escrow
