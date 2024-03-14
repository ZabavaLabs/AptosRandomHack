module nft_tooling::spin_wheel_test {
    use aptos_framework::randomness::{Self};
    use std::string::{Self};
    use std::signer::{Self};
    use aptos_framework::coin::{Self};
    use aptos_framework::aptos_coin::{Self, AptosCoin};
    use aptos_framework::object::{Self, Object};
    use aptos_token_objects::token::{Self, Token};
    use aptos_framework::timestamp;


    #[test_only]
    use aptos_std::crypto_algebra::enable_cryptography_algebra_natives;


    use nft_tooling::random_mint::{Self};
    use nft_tooling::spin_wheel::{Self};

    const TIME_BETWEEN_SPINS: u64 = 24 * 60 * 60 * 1_000_000; 

    // Error Codes
    const ENOT_DEPLOYER: u64 = 1;
    const EINVALID_BALANCE: u64 = 2;
    const ENFT_ID_NOT_FOUND: u64 = 3;
    const EINVALID_TABLE_LENGTH: u64 = 4;
    const EINVALID_PRIZE: u64 = 5;

    // Testing
    #[test(creator = @nft_tooling, fx = @aptos_framework, u1 = @0xA001, u2 = @0xA002)]
    public fun mint_nft_and_spin(creator: &signer, fx: &signer,
        u1: &signer, u2: &signer) {
        enable_cryptography_algebra_natives(fx);

        timestamp::set_time_has_started_for_testing(fx);
        randomness::initialize_for_testing(fx);
        randomness::set_seed(x"0000000000000000000000000000000000000000000000000000000000000001");

        random_mint::setup_coin(creator, u1, u2, fx);
        random_mint::initialize_for_test(creator);

        spin_wheel::initialize_for_test(creator);

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

        // Can assign any weight to the various items
        random_mint::add_nft_entry(creator, name1, description1, uri1, 300);
        random_mint::add_nft_entry(creator, name2, description2, uri2, 100);
        random_mint::add_nft_entry(creator, name3, description3, uri3, 100);
        random_mint::add_nft_entry(creator, name4, description4, uri4, 100);

        assert!(random_mint::get_nft_table_length()==4, EINVALID_TABLE_LENGTH);

        let nft = random_mint::create_nft_for_test(u1, name1, description1, uri1);

        let nft_address = object::object_address(&nft);
        let token = object::address_to_object<Token>(nft_address);
        assert!(spin_wheel::prize_number(token) == 0, EINVALID_PRIZE);
        spin_wheel::spin_with_nft(u1, token);
        assert!(spin_wheel::prize_number(token) != 0, EINVALID_PRIZE);
        spin_wheel::claim_spin_prize(u1, token);
        assert!(spin_wheel::prize_number(token) == 0, EINVALID_PRIZE);

        timestamp::update_global_time_for_test(TIME_BETWEEN_SPINS + 1);
        spin_wheel::spin_with_nft(u1, token);
        spin_wheel::claim_spin_prize(u1, token);

        timestamp::update_global_time_for_test(2 * (TIME_BETWEEN_SPINS + 1));
        spin_wheel::spin_with_nft(u1, token);
        spin_wheel::claim_spin_prize(u1, token);

        timestamp::update_global_time_for_test(3 * (TIME_BETWEEN_SPINS + 1));
        spin_wheel::spin_with_nft(u1, token);
        spin_wheel::claim_spin_prize(u1, token);
    }


  
    


}