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
    const [nftTable, setNftTable] = useState([]);

    const [nameInputText, setNameInputText] = useState('');
    const [descriptionInputText, setDescriptionInputText] = useState('');
    const [uriInputText, setUriInputText] = useState('');
    const [weightInputText, setWeightInputText] = useState();
    // const [tableLength, setTableLength] = useState(0);

    useEffect(() => {
        updateTable()
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
            updateTable()
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
            updateTable()
        } catch (error) {
            console.error(error);
        }
    }

    const getNftInfoEntry = async (ind: number) => {
        const payload: InputViewRequestData = {
            function: `${CONTRACT_ADDR}::random_mint::get_nft_info_entry`,
            typeArguments: [],
            functionArguments: [`${ind}`],
        };
        console.log("getNftInfoEntry")
        try {

            const response = await RANDOMNET_CLIENT.view({ payload: payload });
            console.log(`table response: ${JSON.stringify(response[0])}`)
            return response[0]

            // const newNftTable = [...nftTable];
            // if (ind < newNftTable.length) {
            //     newNftTable[ind] = response[0]
            //     setNftTable(newNftTable)
            // } else {
            //     setNftTable([...newNftTable, response[0]])
            // }
        } catch (e) {
            console.log("Error", e)
        }
    }

    const getNftTableLength = async () => {
        const payload: InputViewRequestData = {
            function: `${CONTRACT_ADDR}::random_mint::get_nft_table_length`,
            typeArguments: [],
            functionArguments: [],
        };
        try {
            const response = await RANDOMNET_CLIENT.view({ payload: payload });
            console.log(`table length response: ${JSON.stringify(response[0])}`)
            return response[0]
            // setTableLength(response[0])

        } catch (e) {
            console.log("Error", e)
        }
    }

    const updateTable = async () => {
        const tableLength = await getNftTableLength()
        const fetchedResults = [];
        for (let i = 0; i < tableLength; i++) {
            const result = await getNftInfoEntry(i)
            fetchedResults.push(result)
            setNftTable([...fetchedResults]);
        }
    }




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
            <div className="flex flex-col w-full p-8 bg-slate-950 rounded-lg mt-8 text-white">
                <h2 className="text-white mb-4 text-2xl">Lootbox Table</h2>
                <table className="">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Description</th>
                            <th>Uri</th>
                            <th>Weight</th>
                        </tr>
                    </thead>
                    <tbody>
                        {nftTable.map((item, index) => (
                            <tr key={index}>
                                <td className="overflow-hidden border px-4 py-2 whitespace-nowrap">{item.name}</td>
                                <td className="overflow-hidden border px-4 py-2 whitespace-nowrap">{item.description}</td>
                                <td className="overflow-hidden border px-4 py-2 whitespace-nowrap">{item.uri}</td>
                                <td className="overflow-hidden border px-4 py-2 whitespace-nowrap">{item.weight}</td>

                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>

        </section>
    );
};

export default AdminTab;