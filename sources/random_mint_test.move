module nft_tooling::random_mint_test {
    use aptos_framework::randomness;
    use std::string::{Self, String};
    use std::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::{Self, AptosCoin};


    #[test_only]
    use aptos_std::crypto_algebra::enable_cryptography_algebra_natives;


    use nft_tooling::random_mint::{Self};

    const APP_OBJECT_SEED: vector<u8> = b"NFT_NAME";
    const NFT_COLLECTION_NAME: vector<u8> = b"My NFT Collection";
    const NFT_COLLECTION_DESCRIPTION: vector<u8> = b"My NFT Collection Description";
    const NFT_COLLECTION_URI: vector<u8> = b"https://cdn.pixabay.com/photo/2012/05/03/23/13/cat-46676_1280.png";


    // Error Codes
    const ENOT_DEPLOYER: u64 = 1;
    const EINVALID_BALANCE: u64 = 2;
    const ENFT_ID_NOT_FOUND: u64 = 3;
    const EINVALID_TABLE_LENGTH: u64 = 4;




    // Testing
    #[test(creator = @nft_tooling, fx = @aptos_framework, u1 = @0xA001, u2 = @0xA002)]
    public fun mint_nft(creator: &signer, fx: &signer,
        u1: &signer, u2: &signer) {
        enable_cryptography_algebra_natives(fx);

        randomness::initialize_for_testing(fx);
        randomness::set_seed(x"0000000000000000000000000000000000000000000000000000000000000001");

        random_mint::setup_coin(creator, u1, u2, fx);
        random_mint::initialize_for_test(creator);


        let name1 = string::utf8(b"name1");
        let description1 = string::utf8(b"description1");
        let uri1 = string::utf8(b"uri1");

        let name2 = string::utf8(b"name2");
        let description2 = string::utf8(b"description2");
        let uri2 = string::utf8(b"uri2");

        let name3 = string::utf8(b"name3");
        let description3 = string::utf8(b"description3");
        let uri3 = string::utf8(b"uri3");

        let name4 = string::utf8(b"name4");
        let description4 = string::utf8(b"description4");
        let uri4 = string::utf8(b"uri4");


        random_mint::add_nft_entry(creator, name1, description1, uri1);
        random_mint::add_nft_entry(creator, name2, description2, uri2);
        random_mint::add_nft_entry(creator, name3, description3, uri3);
        random_mint::add_nft_entry(creator, name4, description4, uri4);

        assert!(random_mint::get_nft_table_length()==4, EINVALID_TABLE_LENGTH);

        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);
        random_mint::mint_nft(u1);

      


        let balance = coin::balance<AptosCoin>(signer::address_of(u1));
        // assert!(balance==2*10_000_000, EINVALID_BALANCE);

    }

    


}