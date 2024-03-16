import { InputTransactionData, useWallet } from '@aptos-labs/wallet-adapter-react';
import React, { useEffect, useState } from 'react';
import { CONTRACT_ADDR, RANDOMNET_CLIENT } from '../../utils';
import { InputViewRequestData, Network } from '@aptos-labs/ts-sdk';
import { useAlert } from '../AlertProvider';
import { genActionStyle } from 'antd/es/alert/style';


const AdminTab: React.FC = () => {
    const { account, connected, network, wallet, signAndSubmitTransaction } = useWallet();
    const { setSuccessAlertMessage, setSuccessAlertHash } = useAlert();
    const [isMintable, setIsMintable] = useState(true);


    useEffect(() => {

    }, [connected])


    const handleAddNft = async (event: React.ChangeEvent<HTMLInputElement>) => {
        event.preventDefault();
        if (!account) return;
        const transaction: InputTransactionData = {
            data: {
                function: `${CONTRACT_ADDR}::random_mint::add_nft_entry`,
                typeArguments: [],
                functionArguments: [nameInputText, descriptionInputText, uriInputText, weightInputText],
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

    const handleClearNftEntries = async (event: React.ChangeEvent<HTMLInputElement>) => {
        event.preventDefault();
        if (!account) return;
        const transaction: InputTransactionData = {
            data: {
                function: `${CONTRACT_ADDR}::random_mint::clear_nft_entries`,
                typeArguments: [],
                functionArguments: [],
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



    const [nameInputText, setNameInputText] = useState('');
    const [descriptionInputText, setDescriptionInputText] = useState('');
    const [uriInputText, setUriInputText] = useState('');
    const [weightInputText, setWeightInputText] = useState();

    // Event handler to update the input text
    const handleNameInputChange = (event: any) => {
        setNameInputText(event.target.value);
    };
    const handleDescriptionInputChange = (event: any) => {
        setDescriptionInputText(event.target.value);
    };
    const handleUriInputChange = (event: any) => {
        setUriInputText(event.target.value);
    };
    const handleWeightInputChange = (event: any) => {
        setWeightInputText(event.target.value);
    };
    return (
        <section className="flex flex-col h-full w-full items-center">
            <div className="flex flex-col max-w-7xl w-full p-8 bg-slate-950 rounded-lg">
                <h2 className="text-white mb-4 text-2xl">Add NFT to lootbox</h2>
                <form className="flex flex-col " action='N'>
                    <input
                        className="py-2 px-6 my-4 rounded-full"
                        type="text"
                        value={nameInputText}
                        onChange={handleNameInputChange}
                        placeholder='NFT Name'
                    />
                    <input
                        className="py-2 px-6 my-4 rounded-full"
                        type="text"
                        value={descriptionInputText}
                        onChange={handleDescriptionInputChange}
                        placeholder='NFT Description'
                    />
                    <input
                        className="py-2 px-6 my-4 rounded-full"
                        type="text"
                        value={uriInputText}
                        onChange={handleUriInputChange}
                        placeholder='ipfs://'
                    />
                    <input
                        className="py-2 px-6 my-4 rounded-full"
                        type="text"
                        value={weightInputText}
                        onChange={handleWeightInputChange}
                        placeholder='Probability weight'
                    />
                    <button onClick={handleAddNft} className=" text-white bg-blue-600 w-96 h-12 mt-4 rounded-full">
                        Add
                    </button>
                    <button onClick={handleClearNftEntries} className=" text-white bg-red-400 w-96 h-12 mt-4 rounded-full">
                        Clear Entries
                    </button>
                </form>
            </div>
            <div className="flex flex-col max-w-7xl w-full p-8 bg-slate-950 rounded-lg mt-8">
                <h2 className="text-white mb-4 text-2xl">Table</h2>
            </div>

        </section>
    );
};

export default AdminTab;