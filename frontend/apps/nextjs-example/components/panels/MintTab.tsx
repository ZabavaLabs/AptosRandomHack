import { InputTransactionData, useWallet } from '@aptos-labs/wallet-adapter-react';
import React, { useEffect, useState } from 'react';
import { CONTRACT_ADDR, RANDOMNET_CLIENT } from '../../utils';
import { InputViewRequestData, Network } from '@aptos-labs/ts-sdk';
import { useAlert } from '../AlertProvider';
import { MediaRenderer } from "@thirdweb-dev/react";

const MintTab: React.FC = () => {
    const { account, connected, network, wallet, signAndSubmitTransaction } = useWallet();
    const { setSuccessAlertMessage, setSuccessAlertHash } = useAlert();
    const [isMintable, setIsMintable] = useState(true);
    const [prizeCid, setPrizeCid] = useState("");



    useEffect(() => {
        getMintStatus()
    }, [isMintable, connected])


    const handleMint = async () => {
        console.log("handleMint1")
        if (!account) return;
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
            getMintStatus();
            getPrize();
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
            getMintStatus();
            getPrize();

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
        try {

            const response = await RANDOMNET_CLIENT.view({ payload: payload });
            console.log(`response: ${response}`)
            setIsMintable(response[0])
        } catch (e) {
            console.log("Error", e)
        }
    }

    const getPrize = async () => {
        if (!account) {
            setIsMintable(true)
            return
        };
        const payload: InputViewRequestData = {
            function: `${CONTRACT_ADDR}::random_mint::get_prize`,
            typeArguments: [],
            functionArguments: [account?.address!],
        };
        try {
            const response = await RANDOMNET_CLIENT.view({ payload: payload });
            // console.log(`response: ${response}`)
            setPrizeCid(response[0])
        } catch (e) {
            console.log("Error", e)
        }
    }

    return (
        <section className="flex h-full w-full justify-center items-center">

            <div className="flex flex-col  2xl:w-1/2 md:w-2/3 w-full rounded-lg h-full max-w-xl justify-center items-center mx-4">
                <div className="bg-slate-950 sm:w-96 w-full my-8 h-96 text-white justify-center items-center flex">
                    {isMintable && <img className="w-32 h-32 absolute aspect-square" src="question-mark-icon.png" alt="Question Mark" />
                    }
                    {!isMintable &&
                        < MediaRenderer
                            src="ipfs://bafybeibygun6pbfe4iajsf3b4bpiqxsxhedzpevkzktxziwlupxg4evhgu"
                            alt="Prize Image"
                            className='flex h-auto w-40'
                        />
                    }
                    {/* <img className="w-56 h-56" src="https://ipfs.io/ipfs/bafybeibygun6pbfe4iajsf3b4bpiqxsxhedzpevkzktxziwlupxg4evhgu"></img> */}
                </div>
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
    );
};

export default MintTab;