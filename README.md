# Bonanza by Zabava Labs
&nbsp;
<div align="center" >
<img width="200" src="readme/Logo.png"/>
</div>
&nbsp;

Zabava labs is a Web3 game studio, and we are currently building a game called Undying City. One of the problems we have encountered is that there is no fast, easy, cheap and secure way to do randomness on-chain. We think that  randomness is a crucial feature for gaming applications like opening lootboxes and rewarding users with randomized daily spins.

During this Aptos Random hack, we decided to build a solution for ourselves.

## Bonanza
We present our project called Bonanza, which offers ways for people to obtain sources of wealth through randomization.

### Randomised On-Chain Lootbox
This allows anyone to create their own lootbox and add NFTs to the lootbox. Only the admin is able to add or remove NFT metadata to the lootbox, and assign relative weights to each particular NFT.

### Marketplace
This allows anyone to list their NFT, where people can submit any amount of bid to potentially buy the NFT, where the probability of winning the NFT is higher with a higher bid. The person who listed the NFT receives APT from all the failed and successful bid.

- Currently the formula is 
- Probability = bidding_price/listing_price
- The formula can easily be changed in the future.


## Smart Contracts
Located in the [source folder](/sources/)

### random_mint
- Smart contract for the lootbox.
- Stores the potential NFT metadata into a smart_table.
- Only the deployer of the smart contract can control the NFT metadata and relative weights of obtaining each NFT.
- Stores the result of the random number into a simple_map of <address, u64>
- User has to claim the prize before attempting to open another lootbox.
- Basic test case for the simple_map approach.
- Does not suffer from undergasing attacks because the result of the randomness is committed in the simple map.
- Also includes code in which the smart contract issues a token to the user, storing the result of the random number. The user then has to send back the token to smart contract to burn it to claim the prize. This is more tedious but overcomes the mint then claim limitation. (Not tested yet.)

### spin_wheel
- Smart contract for the daily rewards.
- Stores the result of the random number into a simple_map of <address, u64>
- Very similar approach taken with the lootbox approach.
- We explore having a different outcome depending on the random number committed.
- Currently, spinning the wheel has 6 possible outcomes.
    1. Win  0.01 APT
    2. Win 0.02 APT
    3. Win 1 NFT
    4. Win 2 NFTs
    5. Win Nothing
    6. Win Nothing
- Basic testing.

### market
- Smart contract for listing, buying, withdrawing and claiming NFT
- User is able to list the NFT. It can only be withdrawn if the NFT has not been successfully bought yet.
- The result of the randomness is committed to a simple_map with the address of the NFT as the key.
- Prevents undergasing by having both paths of winning and losing the NFT be equal in gas cost. 
- Some test cases to ensure that it works.

## Website
The deployed website is 
- https://aptosrandomhack-2-6iiddw2vtq-uc.a.run.app/
- Currently, we have not implemented the daily wheel spinning smart contract on the frontend due to time constraints. The flow should be very similar to the minting and purchasing of lootboxes.
- The code is located in the [frontend folder](/frontend/apps/nextjs-example/)

To use the site:
> Connect your wallet and dake sure you're on the Randomnet with some credits.

1) Add the NFT metadata to the lootbox table 
    - Only the deployer of the smart contract is able to control the Lootbox Table. Reach out to us if you'd like to test it out.
    - Any changes should be reflected on the lootbox table immediately.
 
2) Proceed to the Mint Tab.
    - Mint a random NFT
    - Claim the prize

3) List Tab
    - Allows you to list your NFT that others may potentially buy.
    - Choose from 1 of your owned NFTs to list it.
    - The user can set a listing price for the NFT that they choose to list. At or above the listing price, the bidder has a 100% chance to buy.

4) Buy Tab
    - If you are the lister of the NFT, you can withdraw it, provided it is not bought yet.
    - Submit a bid to buy other NFTs.
    - A Claim Prize button should appear if you win it.


## Roadmap
- We plan to integrate the smart contracts and launch it under certain features of Undying City.