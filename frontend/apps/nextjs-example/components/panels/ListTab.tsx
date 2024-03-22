import { InputTransactionData, useWallet } from '@aptos-labs/wallet-adapter-react';
import React, { useEffect, useState } from 'react';
import { CONTRACT_ADDR, RANDOMNET_CLIENT } from '../../utils';
import { InputViewRequestData, Network } from '@aptos-labs/ts-sdk';
import { useAlert } from '../AlertProvider';
import { MediaRenderer } from "@thirdweb-dev/react";
import TokenCard from '../TokenCard';

const ListTab: React.FC = () => {
    const { account, connected, network, wallet, signAndSubmitTransaction } = useWallet();
    const { setSuccessAlertMessage, setSuccessAlertHash } = useAlert();

    const [tokenArray, setTokenArray] = useState([])
    const [selectedToken, setSelectedToken] = useState(undefined)
    const [priceInputText, setPriceInputText] = useState();

    useEffect(() => {
        getOwnedTokens()
    }, [connected])


    const handleList = async () => {
        console.log("handleList")
        if (!connected) return;
        const transaction: InputTransactionData = {
            data: {
                function: `${CONTRACT_ADDR}::market::list_nft`,
                typeArguments: [],
                functionArguments: [selectedToken?.tokenAddress, priceInputText * 100000000],
            },
        };
        try {
            const response = await signAndSubmitTransaction(transaction);
            await RANDOMNET_CLIENT.waitForTransaction({
                transactionHash: response.hash,
            });
            setSuccessAlertHash(response.hash, Network.RANDOMNET);
            getOwnedTokens();

        } catch (error) {
            console.error(error);
        }
    }

    const getOwnedTokens = async () => {
        if (!connected) {
            return
        };
        const ownedTokens = await RANDOMNET_CLIENT.getAccountOwnedTokens({ accountAddress: account?.address! });
        setTokenArray(ownedTokens)
        console.log("ownedTokens", JSON.stringify(ownedTokens));
    }

    const handleCardClick = (nft: any) => {
        setSelectedToken(nft)
        console.log("Selected Card: ", JSON.stringify(nft))
    }

    const handlePriceInputChange = (event: any) => {
        setPriceInputText(event.target.value);
    };
    return (
        <section className="flex h-full w-full justify-center items-center flex-col">

            <div className="flex flex-row  w-full rounded-lg h-full max-w-4xl justify-center p-12 mx-4 menu-background-color">
                <div className="page-background-color rounded-lg w-96  h-96 text-white justify-center items-center flex mx-4">

                    {selectedToken != undefined &&

                        < MediaRenderer
                            src={`${selectedToken?.tokenUri}`}
                            alt="Selected NFT Image"
                            className='flex h-40 w-40'
                        />
                    }
                </div>
                <div className="w-96 flex flex-col mx-4">
                    <h2 className="w-full text-center text-3xl text-white mb-8 font-bold">Selected NFT</h2>
                    <p className="w-full text-center text-white mb-2">Token Name: {selectedToken?.tokenName}</p>
                    <p className="w-full text-center text-white overflow-hidden mb-2">Token Address: {selectedToken?.tokenAddress}</p>
                    <div className="flex justify-center mt-8 flex-col">
                        <input
                            className="py-3 px-6 my-4 rounded-full"
                            type="text"
                            value={priceInputText}
                            onChange={handlePriceInputChange}
                            placeholder='Listing Price (APT)'
                        />
                        <button className="text-white text-xl button-background-color font-semibold w-full h-16 mt-4 rounded-xl" onClick={handleList}>
                            List NFT
                        </button>
                    </div>
                </div>

            </div>
            <h1 className='text-4xl font-bold text-white m-4 my-12'>
                My NFTs
            </h1>
            <div className="grid grid-cols-3 gap-4 menu-background-color w-full h-full rounded-lg p-12">
                {
                    tokenArray.map((token, index) => {
                        return (<TokenCard key={token.current_token_data.token_data_id}
                            tokenAddress={token.current_token_data.token_data_id}
                            collectionAddress={token.current_token_data.current_collection.collection_id}
                            tokenUri={token.current_token_data.token_uri}
                            tokenName={token.current_token_data.token_name}
                            clickCallback={handleCardClick}
                        />)
                    })
                }
            </div>
        </section>
    );
};

export default ListTab;