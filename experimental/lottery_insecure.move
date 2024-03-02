module lottery::lottery_insecure {
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::coin;
    use aptos_framework::randomness;
    use aptos_std::smart_vector;
    use aptos_std::smart_vector::SmartVector;
    use aptos_framework::coin::Coin;
    use std::signer;
    use std::string::utf8;
    use aptos_std::debug;
    use lottery::lottery_common::{Ticket, new_ticket, get_max_number, find_and_pay_winners};
    use lottery::lottery_common;

    // We need this friend declaration so our tests can call `init_module`.
    friend lottery::lottery_test;

    /// Error code for when a user tries to initate the drawing but no users
    /// bought any tickets.
    const E_NO_TICKETS: u64 = 1;

    /// Error code for when the somebody tries to draw an already-closed lottery
    const E_LOTTERY_HAS_CLOSED: u64 = 2;

    /// Error code for when somebody who is not admin tries to draw the lottery
    const E_ACCESS_DENIED: u64 = 3;

    /// A lottery: a list of users who bought tickets.
    struct Lottery has key {
        tickets: SmartVector<Ticket>,
        coins: Coin<AptosCoin>,
        is_closed: bool,
    }

    /// Initializes the `Lottery` resource, which will maintain the list of lottery tickets bought by users.
    fun init_module(deployer: &signer) {
        move_to(
            deployer,
            Lottery {
                tickets: smart_vector::empty(),
                coins: coin::zero(),
                is_closed: false,
            }
        );
    }

    #[test_only]
    public(friend) fun init_module_for_testing(deployer: &signer) {
        init_module(deployer)
    }

    public fun get_jackpot(): u64 acquires Lottery {
        let lottery = borrow_global_mut<Lottery>(@lottery);
        coin::value(&lottery.coins)
    }

    /// Any user can call this to purchase a ticket in the lottery and guess that the outcome will be `guess`.
    public entry fun buy_a_ticket(user: &signer, guess: u64) acquires Lottery {
        let lottery = borrow_global_mut<Lottery>(@lottery);

        // Charge the price of a lottery ticket from the user's balance, and
        // accumulate it into the lottery's bounty.
        let coins = coin::withdraw<AptosCoin>(user, lottery_common::get_ticket_price());
        coin::merge(&mut lottery.coins, coins);

        // Issue a ticket for that user
        smart_vector::push_back(&mut lottery.tickets, new_ticket(signer::address_of(user), guess))
    }

    /// Can only be called as a top-level call from a TXN, preventing **test-and-abort** attacks (see
    /// [AIP-41](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-41.md)).
    entry fun randomly_pick_winner(admin: &signer) acquires Lottery {
        let _ = randomly_pick_winner_internal(admin);
    }

    /// Allows anyone to close the lottery (if enough time has elapsed & more than
    /// 1 user bought tickets) and to draw a random winner.
    public(friend) fun randomly_pick_winner_internal(admin: &signer): vector<address> acquires Lottery {
        let lottery = borrow_global_mut<Lottery>(@lottery);
        assert!(signer::address_of(admin) == @admin_address, E_ACCESS_DENIED);
        assert!(!lottery.is_closed, E_LOTTERY_HAS_CLOSED);
        assert!(!smart_vector::is_empty(&lottery.tickets), E_NO_TICKETS);

        // Pick the winning lottery number
        let winning_number = randomness::u64_range(0, get_max_number());
        debug::print(&utf8(b"Winning number was:"));
        debug::print(&winning_number);

        // See if anyone won and pay them. If nobody won, additional functionality could be added to move the coins
        // out of the closed `Lottery` resource.
        let winners = find_and_pay_winners(&lottery.tickets, &mut lottery.coins, winning_number);
        lottery.is_closed = true;
        winners
    }
}