import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { WalletConnector } from "@aptos-labs/wallet-adapter-mui-design";
import dynamic from "next/dynamic";
import Image from "next/image";
import { useAutoConnect } from "../components/AutoConnectProvider";
import {
  AccountInfo,
  InputTransactionData,
  NetworkInfo,
  WalletInfo,
} from "@aptos-labs/wallet-adapter-core";
import { useAlert } from "../components/AlertProvider";

import Row from "../components/Row";
import Col from "../components/Col";
import { InputViewRequestData, Network } from "@aptos-labs/ts-sdk";
import { Typography } from "antd";
import { CONTRACT_ADDR, RANDOMNET_CLIENT, aptosClient } from "../utils";
import { useEffect, useState } from "react";


const { Link } = Typography;

const WalletButtons = dynamic(() => import("../components/WalletButtons"), {
  suspense: false,
  ssr: false,
});

const WalletSelectorAntDesign = dynamic(
  () => import("../components/WalletSelectorAntDesign"),
  {
    suspense: false,
    ssr: false,
  }
);

const isSendableNetwork = (connected: boolean, network?: string): boolean => {
  return (
    connected &&
    (network?.toLowerCase() === Network.DEVNET.toLowerCase() ||
      network?.toLowerCase() === Network.TESTNET.toLowerCase())
  );
};

export default function App() {
  const { account, connected, network, wallet, signAndSubmitTransaction } = useWallet();
  const { autoConnect, setAutoConnect } = useAutoConnect();
  const { setSuccessAlertMessage, setSuccessAlertHash } = useAlert();

  const [isMintable, setIsMintable] = useState(true);

  useEffect(() => {
    setAutoConnect(true)
    getMintStatus()
  }, [isMintable, connected])


  const handleMint = async () => {
    console.log("handleMint1")
    if (!account) return;
    console.log("handleMint2")
    const transaction: InputTransactionData = {
      data: {
        function: `${CONTRACT_ADDR}::random_mint::mint_nft`,
        typeArguments: [],
        functionArguments: [], // 1 is in Octas
      },
    };
    try {
      const response = await signAndSubmitTransaction(transaction);
      await RANDOMNET_CLIENT.waitForTransaction({
        transactionHash: response.hash,
      });
      setSuccessAlertHash(response.hash, Network.RANDOMNET);
    } catch (error) {
      console.error(error);
    }
  }

  const handleClaimPrize = async () => {
    if (!account) return;
    const transaction: InputTransactionData = {
      data: {
        function: `${CONTRACT_ADDR}::random_mint::claim_nft_from_map`,
        typeArguments: [],
        functionArguments: [], // 1 is in Octas
      },
    };
    try {
      const response = await signAndSubmitTransaction(transaction);
      await RANDOMNET_CLIENT.waitForTransaction({
        transactionHash: response.hash,
      });
      setSuccessAlertHash(response.hash, Network.RANDOMNET);
    } catch (error) {
      console.error(error);
    }
  }

  const getMintStatus = async () => {
    if (!account) {
      setIsMintable(true)
      return
    };
    const payload: InputViewRequestData = {
      function: `${CONTRACT_ADDR}::random_mint::able_to_mint`,
      typeArguments: [],
      functionArguments: [account?.address!],
    };

    const response = await RANDOMNET_CLIENT.view({ payload: payload });
    console.log(`response: ${response}`)
    setIsMintable(response[0])
  }

  return (
    <div className="flex flex-col h-screen bg-slate-900">
      <nav className="flex flex-row w-full bg-slate-950 py-4 px-4 justify-end h-20">
        <WalletConnector />

      </nav>
      <section className="flex h-full w-full justify-center items-center">
        <div className="flex flex-col  2xl:w-1/2 md:w-2/3 w-full rounded-lg h-full max-w-xl justify-center items-center mx-4">
          <div className="bg-slate-950 sm:w-96 w-full my-8 h-96 text-white">MintBox</div>
          <div className="flex justify-center items-center bg-slate-950 sm:w-96 w-full py-6 rounded-lg">

            {
              isMintable && <button onClick={handleMint} className=" text-white bg-purple-600 w-1/2 h-16 rounded-lg">
                Mint
              </button>
            }
            {
              !isMintable && <button onClick={handleClaimPrize} className="text-white bg-pink-600 w-1/2 h-16 rounded-lg">
                Claim Prize
              </button>
            }
          </div>

        </div>
      </section>
      {/* <section>
        <div className="text-white">
          My NFTs
        </div>
      </section> */}


    </div>
  );
}

