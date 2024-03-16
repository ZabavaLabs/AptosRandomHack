module nft_tooling::spin_wheel {

    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::object::{Self, Object};
    use aptos_std::smart_table::{Self, SmartTable};
    use aptos_std::simple_map::{Self, SimpleMap};

    use aptos_token_objects::collection;
    use aptos_token_objects::token::{Self, Token};
    use std::string::{Self, String};
    use aptos_framework::randomness;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::{Self, AptosCoin};
    use aptos_token_objects::property_map;

    use aptos_framework::timestamp;

    use nft_tooling::random_mint;

    use std::string::utf8;
    use aptos_std::debug;
    use aptos_std::debug::print;

    use std::option;
    use std::signer;

    const EINVALID_COLLECTION: u64 = 1;
    const ECLAIM_FIRST: u64 = 2;


    friend nft_tooling::random_mint_test;

    #[test_only]
    friend nft_tooling::spin_wheel_test;

    // Error Codes
    const ENOT_DEPLOYER: u64 = 1;
    const ENOT_OWNER: u64 = 2;
    const ENFT_ID_NOT_FOUND: u64 = 3;
    const EUNABLE_TO_MINT: u64 = 4;
    const EWEIGHT_ZERO: u64 = 5;
    const EUNABLE_TO_CLAIM: u64 = 6;


    // const MINT_FEE:u64 = 1_000_000;
    // 1 Day
    const TIME_BETWEEN_SPINS: u64 = 24 * 60 * 60 * 1_000_000; 

    const SPIN_SLOTS: u64 = 6;
    const PRIZE_1:u64 = 1_000_000;
    const PRIZE_2:u64 = 2_000_000;
    const PRIZE_3_NFT_ID:u64 = 1;
    const PRIZE_4_NFT_ID_1:u64 = 2;
    const PRIZE_4_NFT_ID_2:u64 = 3;
    


    struct NftMap has key, store, copy {
        simple_map: SimpleMap<address, NftSpinInfo>,
    }

    struct NftSpinInfo has store, copy, drop {
        spin_result: u64,
        timestamp: u64
    }

    fun init_module(deployer: &signer) {
        let simple_map = aptos_std::simple_map::new<address, NftSpinInfo>();

        let nft_map = NftMap {
            simple_map: simple_map,
        };
        move_to(deployer, nft_map);
    }

    // Commits the result of the randomness to a map.
    public(friend) entry fun spin_with_nft(user: &signer, nft: Object<Token> ) acquires NftMap {
        assert!(able_to_spin(nft), ECLAIM_FIRST);  
        assert!(object::is_owner(nft, signer::address_of(user)), ENOT_OWNER);

        let random_number = randomness::u64_range(1, SPIN_SLOTS + 1);
        let nft_addr = object::object_address(&nft);
        
        debug::print(&utf8(b"spin random number was:"));
        debug::print(&random_number);

        let simple_map = &mut borrow_global_mut<NftMap>(@nft_tooling).simple_map;
        let nft_spin_info = NftSpinInfo{
            spin_result: random_number,
            timestamp: timestamp::now_microseconds()
        };
        aptos_std::simple_map::upsert(simple_map, nft_addr, nft_spin_info); 
    }

    // Claim Prize.
    public(friend) entry fun claim_spin_prize(user: &signer, nft: Object<Token> ) acquires NftMap {
        assert!(object::is_owner(nft, signer::address_of(user)), ENOT_OWNER);
        let prize_number = prize_number(nft);
        assert!(prize_number!=0,EUNABLE_TO_CLAIM);

        let nft_addr = object::object_address(&nft);

        // Perform the various actions depending prize number
        if (prize_number == 1){
            coin::transfer<AptosCoin>(user, @nft_tooling, PRIZE_1 );
        } else if (prize_number == 2){
            coin::transfer<AptosCoin>(user, @nft_tooling, PRIZE_2 );
        } else if (prize_number == 3)
        {
            let nft_info_name = random_mint::get_nft_name(PRIZE_3_NFT_ID);  
            let nft_info_description = random_mint::get_nft_description(PRIZE_3_NFT_ID);        
            let nft_info_uri = random_mint::get_nft_uri(PRIZE_3_NFT_ID);        

            random_mint::create_nft(user, 
            nft_info_name, 
            nft_info_description, nft_info_uri, 
            );
        }else if (prize_number == 4)
        {
            let nft_info_name = random_mint::get_nft_name(PRIZE_4_NFT_ID_1);  
            let nft_info_description = random_mint::get_nft_description(PRIZE_4_NFT_ID_1);        
            let nft_info_uri = random_mint::get_nft_uri(PRIZE_4_NFT_ID_1);        

            random_mint::create_nft(user, 
            nft_info_name, 
            nft_info_description, nft_info_uri, 
            );

            let nft_info_name_2 = random_mint::get_nft_name(PRIZE_4_NFT_ID_2);  
            let nft_info_description_2 = random_mint::get_nft_description(PRIZE_4_NFT_ID_2);        
            let nft_info_uri_2 = random_mint::get_nft_uri(PRIZE_4_NFT_ID_2);        

            random_mint::create_nft(user, 
            nft_info_name_2, 
            nft_info_description_2, nft_info_uri_2, 
            );

        };
        

        let simple_map = &mut borrow_global_mut<NftMap>(@nft_tooling).simple_map;
        let nft_spin_info = aptos_std::simple_map::borrow_mut(simple_map, &nft_addr);
        nft_spin_info.spin_result = 0;
    }

    // View function
    #[view]
    public fun able_to_spin(nft: Object<Token>): bool acquires NftMap {
        let nft_map = borrow_global<NftMap>(@nft_tooling);
        let simple_map = nft_map.simple_map;

        let collection = token::collection_object(nft);
        assert!(object::object_address(&collection) == random_mint::nft_collection_address(), EINVALID_COLLECTION);
        let nft_addr = object::object_address(&nft);
        let output = false;
        let contains_key = aptos_std::simple_map::contains_key(&simple_map, &nft_addr);
        if (!contains_key){
            output = true;
            } 
        else {
            let nft_spin_info: NftSpinInfo = *aptos_std::simple_map::borrow(&simple_map, &nft_addr);
            if ( timestamp::now_microseconds() > nft_spin_info.timestamp + TIME_BETWEEN_SPINS && nft_spin_info.spin_result == 0){
                output = true;
            }else{
                output = false
            };
    
        };
        output
    } 

    #[view]
    public fun able_to_claim_spin_prize(nft: Object<Token>): bool acquires NftMap {
        let nft_map = borrow_global<NftMap>(@nft_tooling);
        let simple_map = nft_map.simple_map;

        let collection = token::collection_object(nft);
        assert!(object::object_address(&collection) == random_mint::nft_collection_address(), EINVALID_COLLECTION);
        let nft_addr = object::object_address(&nft);
        let output = false;
        let contains_key = aptos_std::simple_map::contains_key(&simple_map, &nft_addr);
        if (!contains_key){
            output = false;
            } 
        else {
            let nft_spin_info: NftSpinInfo = *aptos_std::simple_map::borrow(&simple_map, &nft_addr);     
            if ( nft_spin_info.spin_result != 0) {
                output = true;
            };
        };
        output
    } 
    
    #[view]
    public fun prize_number(nft: Object<Token>): u64 acquires NftMap {
        let nft_map = borrow_global<NftMap>(@nft_tooling);
        let simple_map = nft_map.simple_map;

        let collection = token::collection_object(nft);
        assert!(object::object_address(&collection) == random_mint::nft_collection_address(), EINVALID_COLLECTION);
        let nft_addr = object::object_address(&nft);
        let output = 0;
        let contains_key = aptos_std::simple_map::contains_key(&simple_map, &nft_addr);
        if (!contains_key){
            output = 0;
            } 
        else {
            let nft_spin_info: NftSpinInfo = *aptos_std::simple_map::borrow(&simple_map, &nft_addr);     
            output = nft_spin_info.spin_result;
        };
        output
    } 

    // Testing functions
    #[test_only]
    public fun initialize_for_testing(creator: &signer) {
        init_module(creator);
    }

    #[test_only]
    public fun setup_coin(creator:&signer, user1:&signer, user2:&signer, aptos_framework: &signer){
        use aptos_framework::account::create_account_for_test;
        create_account_for_test(signer::address_of(creator));
        create_account_for_test(signer::address_of(user1));
        create_account_for_test(signer::address_of(user2));

        let (burn_cap, mint_cap) = aptos_framework::aptos_coin::initialize_for_test(aptos_framework);
        coin::register<AptosCoin>(creator);
        coin::register<AptosCoin>(user1);
        coin::register<AptosCoin>(user2);
        // coin::deposit(signer::address_of(creator), coin::mint(10_00_000_000, &mint_cap));
        // coin::deposit(signer::address_of(user1), coin::mint(10_00_000_000, &mint_cap));
        // coin::deposit(signer::address_of(user2), coin::mint(10_00_000_000, &mint_cap));

        coin::deposit(signer::address_of(creator), coin::mint(100_00_000_000, &mint_cap));
        coin::deposit(signer::address_of(user1), coin::mint(100_00_000_000, &mint_cap));
        coin::deposit(signer::address_of(user2), coin::mint(100_00_000_000, &mint_cap));


        coin::destroy_burn_cap(burn_cap);
        coin::destroy_mint_cap(mint_cap);

    }

}