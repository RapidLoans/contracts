**Contract Deployment on Nile Testnet**

### All contracts are deployd on nile testnet.

- PriceOracle : THFynJj4PuKE6k83VEYMkLods4s9E9iRE5
- LiquidityPool : TNW2bEeTHh7xAMFaUxcpVAym7ZcyCDFn3P
- RapidLoansCore : TQGFMUdmTKC5S5rXaY1UAtjF14M64phMER
- Subject : TPsYJpTEnWvbQd67WwMFpqPdcW9BDnji5b

**What RapidLoans Consists Of**

## PriceOracle

- A simple price oracle that provides conversion rates from TRX to JST and vice verce.
- This is used by the liquidity pool to handle borrow, repay, etc.

## LiquidityPool

Liquidity pool can be accessed on app.rapidloans.vercel

- A simple liquidity pool for TRX/JST token pair, flash loans are issues from this pool itself.
- Users can add liquidity to the pool in TRX or JST for a fixed 15-day period, earning a guaranteed 3% return.
- Users cannot add more liquidity until they withdraw the entire amount after the 15-day period.
- Withdrawals are only allowed after 15 days, including the earned profit.
- If users do not withdraw after 15 days, their balance will no longer accumulate interest, but they can withdraw it at any time thereafter.
- Users can borrow TRX or JST for up to 30 days at a fixed 4% interest rate, provided they have an additional 5% of the equivalent value in the opposite token already invested in the pool.
  - For example, to borrow TRX worth _x_, a user must have JST worth _x_ + 5% invested in the pool.
- Users must repay the loan within 30 days. If they fail to do so, the interest doubles, and the balance of the opposite token pool is unlocked.
- The full loan amount, including interest, must be repaid before or after 30 days (with doubled interest if late), after which the opposite token balance will be unlocked.

## RapidLoansCore

- Core contract that handles the flash loan logic.
- Subject contract calls this contract to request a flash loan.
- When the user requests a loan for eithr TRX or JST, core contract pulls funds from liquidity pool, transfers to subject contract and calls executeRapidLoan on the subject contract which is inherited from IReceiverCOntract on the subject contract.
- When executeRapidLOan is called , core contract checkes wheter the subject returns full repay amount with fee to the core contract.
- All this is done in a single transaction.
- If repay amount has not been given , whole transaction reverts to initial state.

## Subject

- A simple contract demonstrating the flash loan implementation.

**How Can You Request a Flash Loan**

- Checkout app.rapidloans.vecel/flashloans for detailed instructions.
