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

export const CONTRACT_ADDR = "0xc15960d4d41a199fbe4b23aeeec0ba442bd1f0ec5b8b85417dee2aa24ac19c21";
export const APP_SIGNER_CONTRACT_ADDR = "0x1ec2454245f0ba851c99956088c24ee95d839ffe80662a751a07400dd4433f75";