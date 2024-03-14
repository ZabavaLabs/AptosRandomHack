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

export const CONTRACT_ADDR = "0x9084c7d75d142f42546c3639379567da80bfb81ab1e3c0459bbfa45d0564ec9f";