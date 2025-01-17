module nft_tooling::market_test {
    use aptos_framework::randomness::{Self};
    use std::string::{Self};
    use std::signer::{Self};
    use aptos_framework::coin::{Self};
    use aptos_framework::aptos_coin::{Self, AptosCoin};
    use aptos_framework::object::{Self, Object};

    use std::string::utf8;
    use aptos_std::debug;
    use aptos_std::debug::print;

    #[test_only]
    use aptos_std::crypto_algebra::enable_cryptography_algebra_natives;


    use nft_tooling::market::{Self};
    use nft_tooling::random_mint::{Self};

    const APP_SIGNER_CAPABILITY_SEED: vector<u8> = b"APP_SIGNER_CAPABILITY";



    // Error Codes
    const ENOT_DEPLOYER: u64 = 1;
    const ENOT_OWNER: u64 = 2;
    const ENFT_ID_NOT_FOUND: u64 = 3;
    const EINVALID_BUY_STATE:u64 = 4;
    const EINVALID_PARTICIPANT:u64 = 5;
    const EINVALID_NFT_LISTING_STATE:u64 = 6;
    const EINVALID_BALANCE: u64 = 7;




    // Testing
    #[test(creator = @nft_tooling, fx = @aptos_framework, u1 = @0xA001, u2 = @0xA002)]
    public fun market_list_take_down_test(creator: &signer, fx: &signer,
        u1: &signer, u2: &signer) {
        enable_cryptography_algebra_natives(fx);

        randomness::initialize_for_testing(fx);
        randomness::set_seed(x"0000000000000000000000000000000000000000000000000000000000000001");

        market::initialize_for_testing(creator);

        random_mint::setup_coin(creator, u1, u2, fx);
        random_mint::initialize_for_testing(creator);

        let u1_addr = signer::address_of(u1);
        let u2_addr = signer::address_of(u2);


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

        let nft2 = random_mint::create_nft_for_test(u1, name2, description2, uri2);
        let nft1 = random_mint::create_nft_for_test(u1, name1, description1, uri1);
      
        market::list_nft(u1, nft1 , 100_000_000);

        assert!(object::is_owner(nft1, market::get_app_signer_addr()), ENOT_OWNER);
        market::take_down_nft(u1,nft1);
        assert!(object::is_owner(nft1, u1_addr), ENOT_OWNER);

    }

    #[test(creator = @nft_tooling, fx = @aptos_framework, u1 = @0xA001, u2 = @0xA002)]
    #[expected_failure(abort_code=ENOT_OWNER,location=nft_tooling::market)]
    public fun market_list_wrong_take_down(creator: &signer, fx: &signer,
        u1: &signer, u2: &signer) {
        enable_cryptography_algebra_natives(fx);

        randomness::initialize_for_testing(fx);
        randomness::set_seed(x"0000000000000000000000000000000000000000000000000000000000000001");

        market::initialize_for_testing(creator);

        random_mint::setup_coin(creator, u1, u2, fx);
        random_mint::initialize_for_testing(creator);

        let u1_addr = signer::address_of(u1);
        let u2_addr = signer::address_of(u2);


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

        let nft2 = random_mint::create_nft_for_test(u1, name2, description2, uri2);
        let nft1 = random_mint::create_nft_for_test(u1, name1, description1, uri1);
      
        market::list_nft(u1, nft1 , 100_000_000);
        market::take_down_nft(u2, nft1);
    }


    #[test(creator = @nft_tooling, fx = @aptos_framework, u1 = @0xA001, u2 = @0xA002, u3 = @0xA003, u4 = @0xA004 )]
    public fun market_list_multiple_bid_test(creator: &signer, fx: &signer,
        u1: &signer, u2: &signer, u3: &signer, u4: &signer) {
        enable_cryptography_algebra_natives(fx);

        randomness::initialize_for_testing(fx);
        randomness::set_seed(x"0000000000000000000000000000000000000000000000000000000000000001");

        market::initialize_for_testing(creator);

        random_mint::setup_coin_4(creator, u1, u2, u3, u4, fx);
        random_mint::initialize_for_testing(creator);

        let u1_addr = signer::address_of(u1);
        let u2_addr = signer::address_of(u2);
        let u3_addr = signer::address_of(u3);
        let u4_addr = signer::address_of(u4);

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

        let nft2 = random_mint::create_nft_for_test(u1, name2, description2, uri2);
        let nft1 = random_mint::create_nft_for_test(u1, name1, description1, uri1);
      
        market::list_nft(u1, nft1 , 100_000_000);
        assert!(market::get_nft_listing_price(nft1) == 100_000_000, EINVALID_NFT_LISTING_STATE);

        assert!(object::is_owner(nft1, market::get_app_signer_addr()), ENOT_OWNER);
        market::probabilistic_buy(u2, nft1, 10_000_000);
        assert!(market::get_nft_listing_participant(nft1) == u2_addr,EINVALID_NFT_LISTING_STATE);
     
        market::probabilistic_buy(u3, nft1, 10_000_000);
        assert!(market::get_nft_listing_participant(nft1) == u3_addr,EINVALID_NFT_LISTING_STATE);

        market::probabilistic_buy(u4, nft1, 10_000_000);
        assert!(market::get_nft_listing_participant(nft1) == u4_addr,EINVALID_NFT_LISTING_STATE);

        let balance = coin::balance<AptosCoin>(signer::address_of(u1));
        assert!(balance==100_00_000_000 + 30_000_000, EINVALID_BALANCE);

    }

   


}