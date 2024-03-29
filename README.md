# Hardhat Smartcontract Raffle (DDEENNY)
Live Demo Fleek: [https://sparkling-union-7048.on.fleek.co/](https://sparkling-union-7048.on.fleek.co/)

Example Raffle Contract Address: [https://sepolia.etherscan.io/address/0xe88AF1d933aE81F0bD532ECE576b207e1b32D627](https://sepolia.etherscan.io/address/0xe88AF1d933aE81F0bD532ECE576b207e1b32D627)

This is a decentralized raffle application built on the Ethereum blockchain using the Hardhat framework.

## Description

The Hardhat Smart Contract Raffle is a decentralized application (DApp) that allows participants to enter a raffle by purchasing tickets using Ethereum. The raffle follows the following rules:

- One entrance fee for the raffle is 100 USD worth of ETH.
- Participants can only enter the raffle when the status is open.
- If the drawn number is 6, the participant wins the prize.
- If a participant wins, they will receive 90% of the contract balance.
- The remaining 10% of the entrance fee will be transferred to the contract owner.

## Features

- Participants can purchase raffle tickets using Ethereum.
- The winner is selected randomly based on the drawn number.
- Smart contracts ensure the security and transparency of the raffle process.
- Automatic distribution of prizes to the winner's Ethereum address.

## Installation

1. Clone the repository:

```
git clone https://github.com/a399555720/hardhat-smartcontract-raffle-ddeenny
```

2. Install the dependencies using Yarn:
```
cd hardhat-smartcontract-raffle-ddeenny
yarn install
```

3. Configure the Ethereum network settings in the hardhat.config.js file.

4. Deploy the smart contracts:
```
yarn hardhat deploy
```

# Deployment to a testnet or mainnet

1. Setup environment variabltes

You'll want to set your `SEPOLIA_RPC_URL` and `PRIVATE_KEY` as environment variables. You can add them to a `.env` file, similar to what you see in `.env.example`.

- `PRIVATE_KEY`: The private key of your account (like from [metamask](https://metamask.io/)). **NOTE:** FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.
- `SEPOLIA_RPC_URL`: This is url of the sepolia testnet node you're working with. You can get setup with one for free from [Alchemy](https://alchemy.com/?a=673c802981)

2. Get testnet ETH

Head over to [faucets.chain.link](https://faucets.chain.link/) and get some tesnet ETH & LINK. You should see the ETH and LINK show up in your metamask. [You can read more on setting up your wallet with LINK.](https://docs.chain.link/docs/deploy-your-first-contract/#install-and-fund-your-metamask-wallet)

3. Setup a Chainlink VRF Subscription ID

Head over to [vrf.chain.link](https://vrf.chain.link/) and setup a new subscription, and get a subscriptionId. You can reuse an old subscription if you already have one. 

[You can follow the instructions](https://docs.chain.link/docs/get-a-random-number/) if you get lost. You should leave this step with:

1. A subscription ID
2. Your subscription should be funded with LINK

3. Deploy

In your `helper-hardhat-config.js` add your `subscriptionId` under the section of the chainId you're using (aka, if you're deploying to sepolia, add your `subscriptionId` in the `subscriptionId` field under the `11155111` section.)

Then run:
```
yarn hardhat deploy --network sepolia
```

And copy / remember the contract address. 

4. Add your contract address as a Chainlink VRF Consumer

Go back to [vrf.chain.link](https://vrf.chain.link) and under your subscription add `Add consumer` and add your contract address. You should also fund the contract with a minimum of 1 LINK. 

5. Enter your raffle!

You're contract is now setup to be a tamper proof autonomous verifiably random lottery. Enter the lottery by running:

```
yarn hardhat run scripts/enter.js --network sepolia
```

### Estimate gas cost in USD

To get a USD estimation of gas cost, you'll need a `COINMARKETCAP_API_KEY` environment variable. You can get one for free from [CoinMarketCap](https://pro.coinmarketcap.com/signup). 

Then, uncomment the line `coinmarketcap: COINMARKETCAP_API_KEY,` in `hardhat.config.js` to get the USD estimation. Just note, everytime you run your tests it will use an API call, so it might make sense to have using coinmarketcap disabled until you need it. You can disable it by just commenting the line back out. 


## Verify on etherscan

If you deploy to a testnet or mainnet, you can verify it if you get an [API Key](https://etherscan.io/myapikey) from Etherscan and set it as an environemnt variable named `ETHERSCAN_API_KEY`. You can pop it into your `.env` file as seen in the `.env.example`.

In it's current state, if you have your api key set, it will auto verify sepolia contracts!

However, you can manual verify with:

```
yarn hardhat verify --constructor-args arguments.js DEPLOYED_CONTRACT_ADDRESS
```

# Linting

To check linting / code formatting:
```
yarn lint
```
or, to fix: 
```
yarn lint:fix
```

# License
This project is licensed under the MIT License.

# Thank you!
