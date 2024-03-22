import { Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";

export const aptosClient = (network?: string) => {
  if (network === Network.DEVNET.toLowerCase()) {
    return DEVNET_CLIENT;
  } else if (network === Network.TESTNET.toLowerCase()) {
    return TESTNET_CLIENT;
  } else if (network === Network.MAINNET.toLowerCase()) {
    throw new Error("Please use devnet or testnet for testing");
  } else {
    throw new Error(`Unknown network: ${network}`);
  }
};
export const DEVNET_CONFIG = new AptosConfig({
  network: Network.DEVNET,
});
export const DEVNET_CLIENT = new Aptos(DEVNET_CONFIG);
export const TESTNET_CONFIG = new AptosConfig({ network: Network.TESTNET });
export const TESTNET_CLIENT = new Aptos(TESTNET_CONFIG);
export const RANDOMNET_CONFIG = new AptosConfig({ network: Network.RANDOMNET });
export const RANDOMNET_CLIENT = new Aptos(RANDOMNET_CONFIG);

export const CONTRACT_ADDR = "0x1cfbbe1d6d623f09f507c08587d5067beaaa3614ffc503e40512035d37c87a6b";
export const APP_SIGNER_CONTRACT_ADDR = "0x4047ea50c79a056ff38a30febefbc020eee91527a73c26b70c8a42d8746b4f48";