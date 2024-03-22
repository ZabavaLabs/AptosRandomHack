# Bonanza by Zabava Labs

Zabava labs is a Web3 game studio, and we are currently building a game called Undying City. One of the problems we have encountered is that there is no fast, easy, cheap and secure way to do randomness on-chain. We think that  randomness is a crucial feature for gaming applications like opening lootboxes and rewarding users with randomized daily spins.

During this Aptos Random hack, we decided to build a solution for ourselves.

## Bonanza
We present our project called Bonanza, which offers ways for people to obtain sources of wealth through randomization.

### Randomised On-Chain Lootbox
This allows anyone to create their own lootbox and add NFTs to the lootbox. Only the admin is able to add or remove NFT metadata to the lootbox, and assign relative weights to each particular NFT.

### Marketplace
This allows anyone to list their NFT, where people can submit any amount of bid to potentially buy the NFT, where the probability of winning the NFT is higher with a higher bid. The person who listed the NFT receives APT from all the failed and successful bid.

- Currently the formula is 
- Probability = (bidding_price/listing_price)^2
- The formula can easily be changed in the future.


## Smart Contracts
Located [here](/sources/)


## Website
The deployed website is 
- https://aptosrandomhack-2-6iiddw2vtq-uc.a.run.app/
- Currently, we have not implemented the daily wheel spinning smart contract on the frontend due to time constraints. The flow should be very similar to the minting and purchasing of lootboxes.

To use the site:
> Connect your wallet and dake sure you're on the Randomnet with some credits.

1) Add the NFT metadata to the lootbox table 
    - Only the deployer of the smart contract is able to control the Lootbox Table. Reach out to us if you'd like to test it out.
    - Any changes should be reflected on the lootbox table immediately.
 
2) Proceed to the Mint Tab.
