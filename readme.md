**Contract Deployment on Nile Testnet**

- PriceOracle : THFynJj4PuKE6k83VEYMkLods4s9E9iRE5
- LiquidityPool : TNW2bEeTHh7xAMFaUxcpVAym7ZcyCDFn3P
- RapidLoansCore : TQGFMUdmTKC5S5rXaY1UAtjF14M64phMER
- Subject : TPsYJpTEnWvbQd67WwMFpqPdcW9BDnji5b

**What RapidLoans Consists Of**

###Liquidity Pool

- Users can add liquidity to the pool in TRX or JST for a fixed 15-day period, earning a guaranteed 3% return.
- Users cannot add more liquidity until they withdraw the entire amount after the 15-day period.
- Withdrawals are only allowed after 15 days, including the earned profit.
- If users do not withdraw after 15 days, their balance will no longer accumulate interest, but they can withdraw it at any time thereafter.
- Users can borrow TRX or JST for up to 30 days at a fixed 4% interest rate, provided they have an additional 5% of the equivalent value in the opposite token already invested in the pool.
  - For example, to borrow TRX worth _x_, a user must have JST worth _x_ + 5% invested in the pool.
- Users must repay the loan within 30 days. If they fail to do so, the interest doubles, and the balance of the opposite token pool is unlocked.
- The full loan amount, including interest, must be repaid before or after 30 days (with doubled interest if late), after which the opposite token balance will be unlocked.
