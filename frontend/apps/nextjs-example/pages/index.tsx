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
import Tabs from '../components/Tabs';
import MintTab from "../components/panels/MintTab";
import AdminTab from "../components/panels/AdminTab";
import ListTab from "../components/panels/ListTab";
import BuyTab from "../components/panels/BuyTab";

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
  }, [connected])

  const tabs = [
    { label: 'Admin', content: <AdminTab /> },
    { label: 'Mint', content: <MintTab /> },
    { label: 'List', content: <ListTab /> },
    { label: 'Buy', content: <BuyTab /> },
  ];
  const [activeTab, setActiveTab] = useState<number>(1);
  return (
    <div className="flex flex-col h-full min-h-screen bg-slate-900">
      <nav className="flex flex-row w-full bg-slate-950 py-4 px-4 justify-end h-20">
        <WalletConnector />

      </nav>
      <div className="flex h-full w-full flex-col items-center">
        <div className="my-8">
          <Tabs tabs={tabs} activeTab={activeTab} setActiveTab={setActiveTab} />
        </div>

        <div>
          {tabs.map((tab, index) =>
            index === activeTab ? <div className="flex h-full w-full" key={index}>{tab.content}</div> : null
          )}
        </div>
      </div>
    </div>
  );
}

