**Contract Deployment on Nile Testnet**

All contracts are live on the Nile Testnet:

- **PriceOracle**: THFynJj4PuKE6k83VEYMkLods4s9E9iRE5
- **LiquidityPool**: TNW2bEeTHh7xAMFaUxcpVAym7ZcyCDFn3P
- **RapidLoansCore**: TQGFMUdmTKC5S5rXaY1UAtjF14M64phMER
- **Subject**: TPsYJpTEnWvbQd67WwMFpqPdcW9BDnji5b

---

### What is RapidLoans?

RapidLoans is a cutting-edge platform that offers liquidity and flash loans through smart contracts, empowering users to invest, borrow, and earn—all on-chain.

---

### **PriceOracle**

- A reliable oracle providing up-to-date TRX/JST conversion rates.
- Used by the **LiquidityPool** to manage borrowing, repayments, and more.

---

### **LiquidityPool**

Accessible via [app.rapidloans.vercel](https://app.rapidloans.vercel.app/).

- The liquidity pool for the TRX/JST token pair is the fund hub of RapidLoans, from where funds for flash loans are provided.
- Users can deposit TRX or JST for a fixed 15-day term, earning a guaranteed 3% return on their investment.
- Liquidity can only be added after the full withdrawal of the current amount (including profits) once the 15-day period ends.
- Withdrawals can only happen after 15 days, and the full amount along with the earned profit can be withdrawn.
- If users don’t withdraw immediately after 15 days, the balance remains stagnant (no further interest), but can be withdrawn anytime afterward.
- Borrowers can take TRX or JST loans for up to 30 days at a fixed 4% interest rate, with one condition: they must have at least 5% extra of the loan amount in the opposite token already invested in the pool.
  - For instance, borrowing TRX worth _x_ requires JST worth _x_ + 5% already locked in the pool.
- Loans must be repaid within 30 days. If the repayment deadline is missed, the interest doubles, and the collateral (opposite token balance) becomes unlocked.
- The full loan amount, along with interest, must be repaid either before or after 30 days (doubled interest applies if late), after which the collateral will be unlocked.

---

### **RapidLoansCore**

- The central hub of RapidLoans, handling the flash loan process seamlessly.
- **Subject** contracts request loans from this contract.
- When a loan request is made for TRX or JST, the **RapidLoansCore** contract pulls funds from the liquidity pool, transfers them to the **Subject** contract, and triggers the `executeRapidLoan` function.
- The `executeRapidLoan` function (inherited from **IReceiverContract**) ensures that the full loan, plus fees, is repaid in the same transaction.
- If the repayment isn't successful, the entire transaction is reverted, ensuring security and stability.

---

### **Subject**

- A simple example contract that showcases how to request and manage a flash loan through RapidLoans.

---

### **How to Request a Flash Loan**

Head over to [app.rapidloans.vercel/flashloans](https://app.rapidloans.vercel.app/flashloans) for step-by-step instructions on requesting your flash loan today!
