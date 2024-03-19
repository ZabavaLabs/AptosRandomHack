import { InputTransactionData, useWallet } from '@aptos-labs/wallet-adapter-react';
import React, { useEffect, useState } from 'react';
import { APP_SIGNER_CONTRACT_ADDR, CONTRACT_ADDR, RANDOMNET_CLIENT } from '../../utils';
import { InputViewRequestData, Network } from '@aptos-labs/ts-sdk';
import { useAlert } from '../AlertProvider';
import { MediaRenderer } from "@thirdweb-dev/react";
import TokenCard from '../TokenCard';

const BuyTab: React.FC = () => {
    const { account, connected, network, wallet, signAndSubmitTransaction } = useWallet();
    const { setSuccessAlertMessage, setSuccessAlertHash } = useAlert();

    const [tokenArray, setTokenArray] = useState([])
    const [selectedToken, setSelectedToken] = useState(undefined)
    const [listedNft, setListedNft] = useState()
    const [priceInputText, setPriceInputText] = useState(100);
    const [submittedBuy, setSubmittedBuy] = useState(false);


    useEffect(() => {
        getContractOwnedTokens()
    }, [connected])


    const handleBuy = async () => {
        console.log("handleBuy")
        if (!connected) return;
        const transaction: InputTransactionData = {
            data: {
                function: `${CONTRACT_ADDR}::market::probabilistic_buy`,
                typeArguments: [],
                functionArguments: [selectedToken?.tokenAddress, priceInputText],
            },
        };
        try {
            const response = await signAndSubmitTransaction(transaction);
            await RANDOMNET_CLIENT.waitForTransaction({
                transactionHash: response.hash,
            });
            setSuccessAlertHash(response.hash, Network.RANDOMNET);
            getContractOwnedTokens();
            getListedNFTDetails(selectedToken?.tokenAddress)
            setSubmittedBuy(true)
        } catch (error) {
            console.error(error);
        }
    }

    const handleClaimPrize = async () => {
        console.log("handleWithdraw")
        if (!connected) return;
        const transaction: InputTransactionData = {
            data: {
                function: `${CONTRACT_ADDR}::market::claim_prize_nft`,
                typeArguments: [],
                functionArguments: [selectedToken?.tokenAddress],
            },
        };
        try {
            const response = await signAndSubmitTransaction(transaction);
            await RANDOMNET_CLIENT.waitForTransaction({
                transactionHash: response.hash,
            });
            setSuccessAlertHash(response.hash, Network.RANDOMNET);
            getContractOwnedTokens();
            getListedNFTDetails(selectedToken?.tokenAddress)
            setSubmittedBuy(false)
            setSelectedToken(undefined)
        } catch (error) {
            console.error(error);
        }
    }

    const handleWithdraw = async () => {
        console.log("handleWithdraw")
        if (!connected) return;
        const transaction: InputTransactionData = {
            data: {
                function: `${CONTRACT_ADDR}::market::take_down_nft`,
                typeArguments: [],
                functionArguments: [selectedToken?.tokenAddress],
            },
        };
        try {
            const response = await signAndSubmitTransaction(transaction);
            await RANDOMNET_CLIENT.waitForTransaction({
                transactionHash: response.hash,
            });
            setSuccessAlertHash(response.hash, Network.RANDOMNET);
            getContractOwnedTokens();

        } catch (error) {
            console.error(error);
        }
    }

    const getContractOwnedTokens = async () => {
        if (!connected) {
            return
        };
        const ownedTokens = await RANDOMNET_CLIENT.getAccountOwnedTokens({ accountAddress: APP_SIGNER_CONTRACT_ADDR });
        setTokenArray(ownedTokens)
        console.log("contractOwnedTokens", JSON.stringify(ownedTokens));
    }


    const getListedNFTDetails = async (nftAddress: string) => {
        const payload: InputViewRequestData = {
            function: `${CONTRACT_ADDR}::market::get_nft_listing_info`,
            typeArguments: [],
            functionArguments: [nftAddress],
        };
        try {

            const response = await RANDOMNET_CLIENT.view({ payload: payload });
            setListedNft(response[0])
            console.log(`ListedNFTDetails response: ${JSON.stringify(response)}`)
        } catch (e) {
            setListedNft(null)
            console.log("Error", e)
        }
    }

    const handleCardClick = async (nft: any) => {
        setSelectedToken(nft)
        getListedNFTDetails(nft.tokenAddress)
        console.log("Selected Card: ", JSON.stringify(nft))
    }


    const handlePriceInputChange = (event: any) => {
        setPriceInputText(event.target.value);
    };

    function clampToMax(value) {
        return value > 100 ? 100 : value;
    }

    const probability = clampToMax(priceInputText / listedNft?.price * priceInputText / listedNft?.price * 100);
    const won = listedNft?.bought && listedNft?.participant == account?.address
    return (
        <section className="flex h-full w-full justify-center items-center flex-col">

            <div className="flex flex-row max-w-4xl w-full rounded-lg h-full justify-center p-12 mx-4 menu-background-color">
                <div className="page-background-color w-96 h-96 rounded-lg  text-white justify-center items-center flex mx-4 ">

                    {selectedToken != undefined &&
                        < MediaRenderer
                            src={`${selectedToken?.tokenUri}`}
                            alt="Selected NFT Image"
                            className='flex h-40 w-40'
                        />
                    }
                    {/* {selectedToken == undefined && <img className="w-40 h-40" src="question-mark-icon.png" />} */}
                </div>
                <div className="w-96 flex flex-col mx-4">
                    <h2 className="w-full text-center text-3xl text-white mb-8 font-bold">Selected NFT</h2>
                    <h3 className="w-full text-center  text-white mb-2">Listing Price: {listedNft?.price}</h3>
                    <p className="w-full text-center text-white mb-2">Token Name: {selectedToken?.tokenName}</p>
                    <p className="w-full text-center text-white overflow-hidden mb-2">Token Address: {selectedToken?.tokenAddress}</p>
                    <p className="w-full text-center text-2xl font-medium text-green-400 overflow-hidden mb-2 mt-4">Win Probability: {(probability ? probability : 0).toFixed(2)}%</p>
                    {submittedBuy && <p className="text-yellow-400 text-center text-xl my-4">{won ? "Congratulations, You Won!" : "It's not your lucky day! Try again."}</p>}
                    <div className="flex justify-center mt-8 flex-col">

                        {!listedNft?.bought &&
                            (<>
                                <input
                                    className="py-3 px-6 my-4 rounded-full"
                                    type="text"
                                    value={priceInputText}
                                    onChange={handlePriceInputChange}
                                    placeholder='Bidding Price (Octa)'
                                />
                                <button className="text-white text-xl button-background-color w-full h-16 mt-4 rounded-xl  font-semibold"
                                    onClick={handleBuy}>
                                    Buy NFT
                                </button>
                            </>)
                        }
                        {won &&
                            <button className="text-white text-xl bg-purple-600 w-full h-16 mt-4 rounded-xl font-semibold" onClick={handleClaimPrize}>
                                Claim Prize
                            </button>
                        }

                        {!listedNft?.bought && listedNft?.original_owner == account?.address &&

                            <button className="text-white text-xl bg-red-400 w-full h-16 mt-4 rounded-xl font-semibold" onClick={handleWithdraw}>
                                Withdraw NFT
                            </button>
                        }
                    </div>
                </div>

            </div>
            <h1 className='text-4xl font-bold text-white m-4 my-12'>
                Listed NFTs
            </h1>
            <div className="grid grid-cols-3 gap-4 menu-background-color w-full h-full py-8 rounded-lg p-12">
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

export default BuyTab;