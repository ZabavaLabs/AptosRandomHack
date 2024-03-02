module nft_tooling::random_mint {

    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::object::{Self, Object};
    use aptos_std::smart_table::{Self, SmartTable};
    use aptos_token_objects::collection;
    use aptos_token_objects::token::{Self, Token};
    use std::string::{Self, String};
    use aptos_framework::randomness;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::{Self, AptosCoin};
    use aptos_token_objects::property_map;


    use std::string::utf8;
    use aptos_std::debug;
    use aptos_std::debug::print;

    use std::option;
    use std::signer;

    const APP_OBJECT_SEED: vector<u8> = b"NFT_NAME";
    const NFT_COLLECTION_NAME: vector<u8> = b"My NFT Collection";
    const NFT_COLLECTION_DESCRIPTION: vector<u8> = b"My NFT Collection Description";
    const NFT_COLLECTION_URI: vector<u8> = b"https://cdn.pixabay.com/photo/2012/05/03/23/13/cat-46676_1280.png";

    const TICKET_COLLECTION_NAME: vector<u8> = b"Ticket Collection";
    const TICKET_COLLECTION_DESCRIPTION: vector<u8> = b"Collection of tickets are used to redeem NFTs.";
    const TICKET_COLLECTION_URI: vector<u8> = b"https://cdn.pixabay.com/photo/2012/05/03/23/13/cat-46676_1280.png";

    const TICKET_TOKEN_NAME: vector<u8> = b"Ticket Name";
    const TICKET_TOKEN_DESCRIPTION: vector<u8> = b"Ticket which is used to redeem NFTs.";
    const TICKET_TOKEN_URI: vector<u8> = b"https://cdn.pixabay.com/photo/2012/05/03/23/13/cat-46676_1280.png";

    friend nft_tooling::random_mint_test;

    // Error Codes
    const ENOT_DEPLOYER: u64 = 1;
    const ENOT_OWNER: u64 = 2;
    const ENFT_ID_NOT_FOUND: u64 = 3;

    const MINT_FEE:u64 = 1_000_000;

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct NFTCapability has key {
        mutator_ref: token::MutatorRef,
        burn_ref: token::BurnRef,
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct TicketCapability has key {
        mutator_ref: token::MutatorRef,
        burn_ref: token::BurnRef,
        property_mutator_ref: property_map::MutatorRef,
    }

    struct NFTInfoEntry has store, copy, drop {
        name: String,
        description: String,
        uri: String,
        weight: u64
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct NFTInfo has key {
        table: SmartTable<u64, NFTInfoEntry>,
        total_weight: u64
    }

    // Tokens require a signer to create, so this is the signer for the collection
    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct ResourceCapability has key, drop {
        capability: SignerCapability,
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct NFTCollectionCapability has key {
        collection_mutator_ref: collection::MutatorRef
    }


    fun init_module(deployer: &signer) {
        let (signer_resource, token_signer_cap) = account::create_resource_account(
            deployer,
            APP_OBJECT_SEED,
        );


        let nft_description = string::utf8(NFT_COLLECTION_DESCRIPTION);
        let nft_name = string::utf8(NFT_COLLECTION_NAME);
        let nft_uri = string::utf8(NFT_COLLECTION_URI);

        let ticket_description = string::utf8(TICKET_COLLECTION_DESCRIPTION);
        let ticket_name = string::utf8(TICKET_COLLECTION_NAME);
        let ticket_uri = string::utf8(TICKET_COLLECTION_URI);

        let collection_signer = create_nft_collection(&signer_resource, nft_description, nft_name, nft_uri);

        let _ = create_nft_collection(&signer_resource, ticket_description, ticket_name, ticket_uri);
        
        move_to(&collection_signer, ResourceCapability {
            capability: token_signer_cap,
        });

        
        let nft_info_table = aptos_std::smart_table::new();

        let nft_info = NFTInfo{
            table: nft_info_table,
            total_weight: 0
        };
        move_to(&collection_signer, nft_info);
    }

     fun create_nft_collection(signer_resource: &signer, description: String, name: String, uri: String): signer {
        let collection_constructor_ref = collection::create_unlimited_collection(
            signer_resource,
            description,
            name,
            option::none(),
            uri,
        );
        let object_signer = object::generate_signer(&collection_constructor_ref);
        let collection_mutator_ref = collection::generate_mutator_ref(&collection_constructor_ref);

        let collection_capability = NFTCollectionCapability{
            collection_mutator_ref
        };

        move_to(&object_signer, collection_capability);
        object_signer
    }

    // Commits the result of the randomness to a token which is sent to the user.
    public(friend) entry fun mint_nft(user: &signer) acquires ResourceCapability, NFTInfo {
        let random_number = randomness::u64_range(0, get_nft_total_weight());
        debug::print(&utf8(b"random number was:"));
        debug::print(&random_number);
        coin::transfer<AptosCoin>(user, @nft_tooling, MINT_FEE);

        create_ticket(user, random_number);
    }

    // User uses the token to claim the nft
    public entry fun claim_nft(user: &signer, random_number_token: Object<Token>) acquires ResourceCapability, NFTInfo, TicketCapability {
        assert!(token::creator(random_number_token) == signer::address_of(&get_token_signer()), ENFT_ID_NOT_FOUND);
        assert!(object::is_owner(random_number_token, signer::address_of(user)), ENOT_OWNER);

        let random_number = property_map::read_u64(&random_number_token, &string::utf8(b"RANDOM_NUMBER"));
        let table_length = get_nft_table_length();
        let i = 0;
        let sum = 0;
        let nft_id = 0;
        let next_sum = 0;
        while (i < table_length) {
            let current_weight = get_nft_info_entry(i).weight;
            next_sum = sum + current_weight;
            if (random_number >= sum && random_number < next_sum) {
                nft_id = i;
                assert!(nft_id_exists(nft_id), ENFT_ID_NOT_FOUND);
                burn_ticket(user, random_number_token);
                let nft_info_entry = get_nft_info_entry(nft_id);        
                create_nft(user, 
                nft_info_entry.name, 
                nft_info_entry.description, nft_info_entry.uri, 
                );
                break
            };
            sum = next_sum;
            i = i + 1;
        };

    }

    fun create_nft(
        user: &signer,
        token_name: String, 
        token_description: String, token_uri: String, 
    ): Object<NFTCapability> acquires ResourceCapability {

        let constructor_ref = token::create(
            &get_token_signer(),
            string::utf8(NFT_COLLECTION_NAME),
            token_description,
            token_name,
            option::none(),
            token_uri,
        );

        let token_signer = object::generate_signer(&constructor_ref);
        let mutator_ref = token::generate_mutator_ref(&constructor_ref);
        let burn_ref = token::generate_burn_ref(&constructor_ref);
   

        let new_nft = NFTCapability {
            mutator_ref,
            burn_ref

        };

        move_to(&token_signer, new_nft);
        let created_token = object::object_from_constructor_ref<Token>(&constructor_ref);
        object::transfer(&get_token_signer() , created_token, signer::address_of(user));
        object::address_to_object(signer::address_of(&token_signer))
    }

    fun create_ticket(
        user: &signer,
        random_number: u64
    ): Object<TicketCapability> acquires ResourceCapability {

        let constructor_ref = token::create(
            &get_token_signer(),
            string::utf8(TICKET_COLLECTION_NAME),
            string::utf8(TICKET_TOKEN_DESCRIPTION),
            string::utf8(TICKET_TOKEN_NAME),
            option::none(),
            string::utf8(TICKET_TOKEN_URI),
        );

        let token_signer = object::generate_signer(&constructor_ref);
        let mutator_ref = token::generate_mutator_ref(&constructor_ref);
        let burn_ref = token::generate_burn_ref(&constructor_ref);
        let property_mutator_ref = property_map::generate_mutator_ref(&constructor_ref);
   
        let properties = property_map::prepare_input(vector[], vector[], vector[]);
        property_map::init(&constructor_ref, properties);
        property_map::add_typed(
            &property_mutator_ref,
            string::utf8(b"RANDOM_NUMBER"),
            random_number
        );

        let new_ticket = TicketCapability {
            mutator_ref,
            burn_ref,
            property_mutator_ref
        };

        move_to(&token_signer, new_ticket);
        let created_token = object::object_from_constructor_ref<Token>(&constructor_ref);
        object::transfer(&get_token_signer() , created_token, signer::address_of(user));
        object::address_to_object(signer::address_of(&token_signer))
    }

    public entry fun add_nft_entry(
        account: &signer, 
        name: String, 
        description: String, 
        uri: String,
        weight: u64
        ) acquires NFTInfo {

        assert!(signer::address_of(account) == @nft_tooling ,ENOT_DEPLOYER);

        let nft_info = borrow_global_mut<NFTInfo>(nft_collection_address());
        nft_info.total_weight = nft_info.total_weight + weight;
        let nft_info_table = &mut borrow_global_mut<NFTInfo>(nft_collection_address()).table;
        let table_length = aptos_std::smart_table::length(nft_info_table);

        let nft_info_entry = NFTInfoEntry{
            name,
            description,
            uri,
            weight
        };
        smart_table::add(nft_info_table, table_length, nft_info_entry);
    }

    fun burn_ticket(from: &signer, ticket_token: Object<Token>) acquires TicketCapability{
        assert!(object::is_owner(ticket_token, signer::address_of(from)), ENOT_OWNER);
        let retrieved_ticket_token = move_from<TicketCapability>(object::object_address(&ticket_token));
        let TicketCapability {
            mutator_ref,
            burn_ref,
            property_mutator_ref
        } = retrieved_ticket_token;
        token::burn(burn_ref);
    }

    // Utility function
    fun get_token_signer(): signer acquires ResourceCapability {
        account::create_signer_with_capability(&borrow_global<ResourceCapability>(nft_collection_address()).capability)
    }

    // View function
    #[view]
    public fun nft_id_exists(nft_id: u64): bool acquires NFTInfo {
        let nft_info_table = &borrow_global<NFTInfo>(nft_collection_address()).table;
        smart_table::contains(nft_info_table, nft_id)
    }
    
    #[view]
    public fun capability_address(): address {
        account::create_resource_address(&@nft_tooling, APP_OBJECT_SEED)
    }

    #[view]
    public fun nft_collection_address(): address {
        collection::create_collection_address(&capability_address(), &string::utf8(NFT_COLLECTION_NAME))
    }

    #[view]
    public fun ticket_collection_address(): address {
        collection::create_collection_address(&capability_address(), &string::utf8(TICKET_COLLECTION_NAME))
    }

    #[view]
    public fun get_nft_info_entry(nft_id: u64): NFTInfoEntry acquires NFTInfo {
        let nft_info_table = &borrow_global<NFTInfo>(nft_collection_address()).table;
        *smart_table::borrow(nft_info_table, nft_id)
    }

    #[view]
    public fun get_nft_table_length(): u64 acquires NFTInfo {
        let nft_info_table = &borrow_global<NFTInfo>(nft_collection_address()).table;
        aptos_std::smart_table::length(nft_info_table)
    } 

    #[view]
    public fun get_nft_total_weight(): u64 acquires NFTInfo {
       let nft_info = borrow_global<NFTInfo>(nft_collection_address());
       nft_info.total_weight
    } 
    
    // Testing functions
    #[test_only]
    public fun initialize_for_test(creator: &signer) {
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