module challenge::marketplace;

use challenge::hero::Hero;
use sui::coin::{Self, Coin};
use sui::event;
use sui::sui::SUI;

// ========= ERRORS =========

const EInvalidPayment: u64 = 1;

// ========= STRUCTS =========

public struct ListHero has key, store {
    id: UID,
    nft: Hero,
    price: u64,
    seller: address,
}

// ========= CAPABILITIES =========

public struct AdminCap has key, store {
    id: UID,
}

// ========= EVENTS =========

public struct HeroListed has copy, drop {
    list_hero_id: ID,
    price: u64,
    seller: address,
    timestamp: u64,
}

public struct HeroBought has copy, drop {
    list_hero_id: ID,
    price: u64,
    buyer: address,
    seller: address,
    timestamp: u64,
}

// ========= FUNCTIONS =========

fun init(ctx: &mut TxContext) 
{

    // NOTE: The init function runs once when the module is published
    // TODO: Initialize the module by creating AdminCap
        // Hints:
        // Create AdminCap id with object::new(ctx)
    // TODO: Transfer it to the module publisher (ctx.sender()) using transfer::public_transfer() function

    let adminCap = AdminCap
    {
        id: object::new(ctx)
    };
    transfer::public_transfer(adminCap, ctx.sender());
}

public fun list_hero(nft: Hero, price: u64, ctx: &mut TxContext) 
{

    // TODO: Create a list_hero object for marketplace
        // Hints:
        // - Use object::new(ctx) for unique ID
        // - Set nft, price, and seller (ctx.sender()) fields
    // TODO: Emit HeroListed event with listing details (Don't forget to use object::id(&list_hero) )
    // TODO: Use transfer::share_object() to make it publicly tradeable
    let list_hero = ListHero
    {
            // TODO: Define the fields for the ListHero object
            // 1. Create the object id for the ListHero object
            // 2. The nft object
            // 3. The price of the Hero
            // 4. The seller of the Hero (the sender)
            id: object::new(ctx),
            nft,
            price,
            seller: ctx.sender()
        };

        // TODO: Emit the HeroListed event
        event::emit(HeroListed{ list_hero_id: object::id(&list_hero), price, seller: ctx.sender(), timestamp: ctx.epoch_timestamp_ms() });
        // TODO: Share the ListHero object 

        transfer::share_object(list_hero);
}

#[allow(lint(self_transfer))]
public fun buy_hero(list_hero: ListHero, coin: Coin<SUI>, ctx: &mut TxContext) 
{

    // TODO: Destructure list_hero to get id, nft, price, and seller
        // Hints:
        // let ListHero { id, nft, price, seller } = list_hero;
    // TODO: Use assert! to verify coin value equals listing price (coin::value(&coin) == price) else abort with `EInvalidPayment`
    // TODO: Transfer coin to seller (use transfer::public_transfer() function)
    // TODO: Transfer hero NFT to buyer (ctx.sender())
    // TODO: Emit HeroBought event with transaction details (Don't forget to use object::uid_to_inner(&id) )
    // TODO: Delete the listing ID (object::delete(id))

    let ListHero { id, nft, price, seller} = list_hero;
    // TODO: Assert the price of the Hero is equal to the coin amount
    assert!(coin::value(&coin) == price, 1);
    // TODO: Transfer the coin to the seller
    transfer::public_transfer(coin, seller);
    // TODO: Transfer the Hero object to the sender
    transfer::public_transfer(nft, ctx.sender());
    // TODO: Emit the HeroBought event
    event::emit(HeroBought{ list_hero_id: id.to_inner(), price, buyer: ctx.sender(), seller, timestamp: ctx.epoch_timestamp_ms() });
    // TODO: Destroy the ListHero object
    id.delete();
}

// ========= ADMIN FUNCTIONS =========

public fun delist(_: &AdminCap, list_hero: ListHero) 
{
    let ListHero { id, nft, price: _, seller} = list_hero;
    // NOTE: The AdminCap parameter ensures only admin can call this
    // TODO: Implement admin delist functionality
        // Hints:
        // Destructure list_hero (ignore price with "price: _")
    // TODO:Transfer NFT back to original seller
    // TODO:Delete the listing ID (object::delete(id))
    transfer::public_transfer(nft, seller);
    object::delete(id);
}

public fun change_the_price(_: &AdminCap, list_hero: &mut ListHero, new_price: u64) 
{
    
    // NOTE: The AdminCap parameter ensures only admin can call this
    // list_hero has &mut so price can be modified     
    // TODO: Update the listing price
        // Hints:
        // Access the price field of list_hero and update it
        list_hero.price = new_price;
}

// ========= GETTER FUNCTIONS =========

#[test_only]
public fun listing_price(list_hero: &ListHero): u64 {
    list_hero.price
}

// ========= TEST ONLY FUNCTIONS =========

#[test_only]
public fun test_init(ctx: &mut TxContext) {
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };
    transfer::transfer(admin_cap, ctx.sender());
}

