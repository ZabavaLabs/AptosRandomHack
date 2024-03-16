module nft_tooling::market {

    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::object::{Self, Object};
    use aptos_std::smart_table::{Self, SmartTable};
    use aptos_std::simple_map::{Self, SimpleMap};
    use aptos_framework::object::ExtendRef;
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
    const EMIN_PRICE: u64 = 3;
    
    const PROB_SF:u256 = 100_000; 
    const APP_SIGNER_CAPABILITY_SEED: vector<u8> = b"APP_SIGNER_CAPABILITY";



    #[test_only]
    friend nft_tooling::market_test;

    // Error Codes
    const ENOT_DEPLOYER: u64 = 1;
    const ENOT_OWNER: u64 = 2;
    const ENFT_ID_NOT_FOUND: u64 = 3;
    const EINVALID_BUY_STATE:u64 = 4;
    const EINVALID_PARTICIPANT:u64 = 5;



    struct ObjectController has key {
        app_extend_ref: ExtendRef,
    }

    struct NftListingMap has key, store, copy {
        simple_map: SimpleMap<address, NftListingInfo>,
    }

    struct NftListingInfo has store, copy, drop {
        original_owner: address,
        price: u64,
        bought: bool,
        participant: address
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct ResourceCapability has key, drop {
        signer_capability: SignerCapability,
    }

    fun init_module(deployer: &signer) {

        let constructor_ref = object::create_named_object(
            deployer,
            APP_SIGNER_CAPABILITY_SEED,
        );
        let app_signer = object::generate_signer(&constructor_ref);
        let extend_ref = object::generate_extend_ref(&constructor_ref);

        move_to(&app_signer, ObjectController {
            app_extend_ref: extend_ref,
        });


        let simple_map = aptos_std::simple_map::new<address, NftListingInfo>();

        let nft_map = NftListingMap {
            simple_map: simple_map,
        };
        move_to(deployer, nft_map);


    }

    // List NFT.
    public(friend) entry fun list_nft(user: &signer, nft: Object<Token>, price: u64 ) acquires NftListingMap {
        let caller_addr = signer::address_of(user);
        assert!(object::is_owner(nft, caller_addr), ENOT_OWNER);
        assert!(price >= 100, EMIN_PRICE);
        // TODO:Send Object
        object::transfer(user, nft, get_app_signer_addr());
        let nft_addr = object::object_address(&nft);
        
        let simple_map = &mut borrow_global_mut<NftListingMap>(@nft_tooling).simple_map;
        let nft_listing_info = NftListingInfo{
            original_owner: caller_addr,
            price: price,
            bought: false,
            participant: caller_addr
        };
        aptos_std::simple_map::add(simple_map, nft_addr, nft_listing_info); 
    }

    public(friend) entry fun take_down_nft(user: &signer, nft: Object<Token> ) acquires NftListingMap, ObjectController {
        let caller_addr = signer::address_of(user);
        assert!(able_to_buy_nft(nft), EINVALID_BUY_STATE);
        assert!(get_nft_listing_original_owner(nft) == caller_addr, ENOT_OWNER);
        // TODO:Send Object back to owner
        object::transfer(&get_app_signer(), nft, caller_addr);
        

        let nft_addr = object::object_address(&nft);
        
        let simple_map = &mut borrow_global_mut<NftListingMap>(@nft_tooling).simple_map;

        aptos_std::simple_map::remove(simple_map, &nft_addr); 
    }

    public(friend) entry fun probabilistic_buy(user: &signer, nft: Object<Token>, bid_price:u64 ) acquires NftListingMap {
        let caller_addr = signer::address_of(user);
        assert!(able_to_buy_nft(nft), EINVALID_BUY_STATE);
        assert!(bid_price >= 100, EMIN_PRICE);
        let original_owner = get_nft_listing_original_owner(nft);

        coin::transfer<AptosCoin>(user, original_owner, bid_price );
        let nft_addr = object::object_address(&nft);

        let listing_price = get_nft_listing_price(nft);

        let simple_map = &mut borrow_global_mut<NftListingMap>(@nft_tooling).simple_map;

        let nft_listing_info;
        let bid_price_2_sf = ((bid_price as u256) * (bid_price as u256) * PROB_SF) ;
        let listing_price_2 = (listing_price * listing_price as u256);
        let probability_number_limit = bid_price_2_sf / listing_price_2;
        let random_number = randomness::u256_range(1, PROB_SF + 1);

        debug::print(&utf8(b"Probabilistic buy random number:"));
        debug::print(&random_number);

        // Assuming that the gas cost for each path is the same, so no undergasing attack. 
        if (random_number > probability_number_limit){
            // Lose Condition
            nft_listing_info = NftListingInfo{
                original_owner: original_owner,
                price: listing_price,
                bought: false,
                participant: caller_addr
            };
        } else{
            // Win Condition
            nft_listing_info = NftListingInfo{
                original_owner: original_owner,
                price: listing_price,
                bought: true,
                participant: caller_addr
            };
        };
        
        aptos_std::simple_map::upsert(simple_map, nft_addr, nft_listing_info); 
    }

    public(friend) entry fun claim_prize_nft(user: &signer, nft: Object<Token>) acquires NftListingMap, ObjectController {
        assert!(!able_to_buy_nft(nft), EINVALID_BUY_STATE);
        let caller_addr = signer::address_of(user);
        let participant = get_nft_listing_participant(nft);
        assert!(participant == caller_addr, EINVALID_PARTICIPANT);

        // Send NFT back to participant
        object::transfer(&get_app_signer(), nft, participant);

        let nft_addr = object::object_address(&nft);

        let simple_map = &mut borrow_global_mut<NftListingMap>(@nft_tooling).simple_map;
        aptos_std::simple_map::remove(simple_map, &nft_addr); 
    }

   
    #[view]
    public fun able_to_buy_nft(nft: Object<Token>): bool acquires NftListingMap {
        let nft_map = borrow_global<NftListingMap>(@nft_tooling);
        let simple_map = nft_map.simple_map;
        let nft_addr = object::object_address(&nft);
        let output = false;
        let contains_key = aptos_std::simple_map::contains_key(&simple_map, &nft_addr);
        if (!contains_key){
            output = false;
            } 
        else {
            let nft_listing_info: NftListingInfo = *aptos_std::simple_map::borrow(&simple_map, &nft_addr);     
            output = !nft_listing_info.bought;
        };
        output
    } 

    #[view]
    public fun get_nft_listing_original_owner(nft: Object<Token>): address acquires NftListingMap {
        let nft_map = borrow_global<NftListingMap>(@nft_tooling);
        let simple_map = nft_map.simple_map;
        let nft_addr = object::object_address(&nft);
        let nft_listing_info: NftListingInfo = *aptos_std::simple_map::borrow(&simple_map, &nft_addr);     
        nft_listing_info.original_owner
    } 

    
    #[view]
    public fun get_nft_listing_price(nft: Object<Token>): u64 acquires NftListingMap {
        let nft_map = borrow_global<NftListingMap>(@nft_tooling);
        let simple_map = nft_map.simple_map;
        let nft_addr = object::object_address(&nft);
        let nft_listing_info: NftListingInfo = *aptos_std::simple_map::borrow(&simple_map, &nft_addr);     
        nft_listing_info.price
    } 

    #[view]
    public fun get_nft_listing_info(nft: Object<Token>): NftListingInfo acquires NftListingMap {
        let nft_map = borrow_global<NftListingMap>(@nft_tooling);
        let simple_map = nft_map.simple_map;
        let nft_addr = object::object_address(&nft);
        let nft_listing_info: NftListingInfo = *aptos_std::simple_map::borrow(&simple_map, &nft_addr); 
        nft_listing_info
    } 

    #[view]
    public fun get_nft_listing_participant(nft: Object<Token>): address acquires NftListingMap {
        let nft_listing_info = get_nft_listing_info(nft);
        nft_listing_info.participant
    } 

   

    #[view]
    public fun get_app_signer_addr(): address {
        object::create_object_address(&@nft_tooling, APP_SIGNER_CAPABILITY_SEED)
    }

    #[view]
    fun get_app_signer(): signer acquires ObjectController {
        object::generate_signer_for_extending(&borrow_global<ObjectController>(get_app_signer_addr()).app_extend_ref)
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