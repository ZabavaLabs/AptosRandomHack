import { BitgetWallet } from "@bitget-wallet/aptos-wallet-adapter";
import { BloctoWallet } from "@blocto/aptos-wallet-adapter-plugin";
import { FaceWallet } from "@haechi-labs/face-aptos-adapter-plugin";
import { FewchaWallet } from "fewcha-plugin-wallet-adapter";
import { FlipperWallet } from "@flipperplatform/wallet-adapter-plugin";
import { MartianWallet } from "@martianwallet/aptos-wallet-adapter";
import { NightlyWallet } from "@nightlylabs/aptos-wallet-adapter-plugin";
import { OpenBlockWallet } from "@openblockhq/aptos-wallet-adapter";
import { PetraWallet } from "petra-plugin-wallet-adapter";
import { PontemWallet } from "@pontem/wallet-adapter-plugin";
import { RiseWallet } from "@rise-wallet/wallet-adapter";
import { TokenPocketWallet } from "@tp-lab/aptos-wallet-adapter";
import { TrustWallet } from "@trustwallet/aptos-wallet-adapter";
import { MSafeWalletAdapter } from "@msafe/aptos-wallet-adapter";
import { WelldoneWallet } from "@welldone-studio/aptos-wallet-adapter";
import { OKXWallet } from "@okwallet/aptos-wallet-adapter";
import { OnekeyWallet } from "@onekeyfe/aptos-wallet-adapter";
import {
  AptosWalletAdapterProvider,
  NetworkName,
} from "@aptos-labs/wallet-adapter-react";
import { AutoConnectProvider, useAutoConnect } from "./AutoConnectProvider";
import { FC, ReactNode } from "react";
import face from "../lib/faceInitialization";
import { AlertProvider, useAlert } from "./AlertProvider";
import { IdentityConnectWallet } from "@identity-connect/wallet-adapter-plugin";
import { RANDOMNET_CLIENT } from "../utils";
import { Network } from "@aptos-labs/ts-sdk";

const WalletContextProvider: FC<{ children: ReactNode }> = ({ children }) => {
  const { autoConnect } = useAutoConnect();
  const { setErrorAlertMessage } = useAlert();

  const wallets = [
    // TODO IdentityConnectWallet and BloctoWallet to use Network enum from @aptos-labs/ts-sdk
    new IdentityConnectWallet("9a43ad77-2cbe-4e51-a8d8-8ebde86e6110", {
      networkName: Network.RANDOMNET,
    }),
    // Blocto supports Testnet/Mainnet for now.
    new BitgetWallet(),
    new BloctoWallet({
      network: NetworkName.Testnet,
      bloctoAppId: "6d85f56e-5f2e-46cd-b5f2-5cf9695b4d46",
    }),
    new FaceWallet(face!),
    new FewchaWallet(),
    new FlipperWallet(),
    new MartianWallet(),
    new MSafeWalletAdapter(),
    new NightlyWallet(),
    new OpenBlockWallet(),
    new PetraWallet(),
    new PontemWallet(),
    new RiseWallet(),
    new TokenPocketWallet(),
    new TrustWallet(),
    new WelldoneWallet(),
    new OKXWallet(),
    new OnekeyWallet(),
  ];

  return (
    <AptosWalletAdapterProvider
      plugins={wallets}
      autoConnect={autoConnect}
      onError={(error) => {
        console.log("Custom error handling", error);
        setErrorAlertMessage(error);
      }}
    >
      {children}
    </AptosWalletAdapterProvider>
  );
};

export const AppContext: FC<{ children: ReactNode }> = ({ children }) => {
  return (
    <AutoConnectProvider>
      <AlertProvider>
        <WalletContextProvider>{children}</WalletContextProvider>
      </AlertProvider>
    </AutoConnectProvider>
  );
};
