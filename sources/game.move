module Wedding::marketplace {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext, sender};
    use sui::package::{Self, Publisher};
    use sui::transfer;
    use sui::table::{Self, Table};
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::sui::{SUI};

    use std::string::{String};
    use std::vector::{Self};
    use std::option::{Self, Option};

    const ERROR_WEDDING_TAKEN: u64 = 0;
    const ERROR_INSUFFCIENT_FUNDS: u64 = 1;
    const ERROR_NOT_OWNER: u64 = 2;

    /// Wedding package with price and details
    struct WeddingPackage has key {
        id: UID,
        vendor_id: ID,
        name: String,
        price: u64,
        balance: Balance<SUI>,
        details: String,
        taken: Option<address>,
        active: bool,
        review: Table<address,CustomerReview >
    }

    struct WeddingCap has key, store {
        id: UID,
        for: ID
    }

    /// Booking struct representing a booking made by a couple
    struct Booking has key {
        id: UID,
        vendor_id: ID,
        customer_id: ID,
        wedding_date: u64,  // Using u64 for simplicity
        status: String,     // e.g., "Booked", "Confirmed", etc.
    }

    /// Customer Review struct
    struct CustomerReview has store, copy, drop {
        rating: u8,           // Rating out of 10
        comments: String,     // Customer comments
    }

    /// Customer struct representing a customer in the marketplace
    struct Customer has key {
        id: UID,
        name: String,
        email: String,
        contact_number: String,
    }

    /// Admin capability
    struct AdminCap has key {
        id: UID,
    }

    /// Initialize the marketplace and transfer Admin capability to the initializer
    fun init(ctx: &mut TxContext) {
        // Create AdminCap and transfer it to the context sender
        transfer::transfer(AdminCap { id: object::new(ctx) }, tx_context::sender(ctx));
    }

    // Functions to create new entities

    public fun create_customer(
        name: String,
        email: String,
        contact_number: String,
        ctx: &mut TxContext,
    ): Customer {
        Customer {
            id: object::new(ctx),
            name,
            email,
            contact_number,
        }
    }

    public fun new(
        vendor_id: ID,
        name: String,
        price: u64,
        details: String,
        ctx: &mut TxContext,
    ) : WeddingCap {
        let id_ = object::new(ctx);
        let inner_ = object::uid_to_inner(&id_);
        transfer::share_object(WeddingPackage {
            id: id_,
            vendor_id,
            name,
            price,
            balance: balance::zero(),
            details,
            taken: option::none(),
            active: false,
            review: table::new(ctx)
        });

        WeddingCap{
            id: object::new(ctx),
            for: inner_
        }
    }

    public fun take(self: &mut WeddingPackage, coin: Coin<SUI>, ctx: &mut TxContext) {
        assert!(!self.active, ERROR_WEDDING_TAKEN);
        assert!(coin::value(&coin) == self.price, ERROR_INSUFFCIENT_FUNDS);
        // put the coin to the share object 
        coin::put(&mut self.balance, coin);
        option::fill(&mut self.taken, sender(ctx));
        self.active = true;
    }

    public fun feedback(self: &mut WeddingPackage, rating_: u8, comments_: String, ctx: &mut TxContext) {
        assert!(self.active, ERROR_WEDDING_TAKEN);
        let review = CustomerReview {
            rating: rating_,
            comments: comments_
        };
        table::add(&mut self.review, sender(ctx), review);
    }

    public fun withdraw(cap: &WeddingCap, self: &mut WeddingPackage, ctx: &mut TxContext) : Coin<SUI> {
        assert!(object::id(self) == cap.for, ERROR_NOT_OWNER);
        let amount = balance::value(&self.balance);
        let coin_ = coin::take(&mut self.balance, amount, ctx);
        coin_
    }

    public fun create_booking(
        vendor_id: ID,
        customer_id: ID,
        wedding_date: u64,
        status: String,
        ctx: &mut TxContext,
    ): Booking {
        Booking {
            id: object::new(ctx),
            vendor_id,
            customer_id,
            wedding_date,
            status,
        }
    }

    // Functions to read data

    public fun get_package(package: &WeddingPackage): &WeddingPackage {
        package
    }

    public fun get_booking(booking: &Booking): &Booking {
        booking
    }

    public fun get_review(review: &CustomerReview): &CustomerReview {
        review
    }

    public fun get_customer(customer: &Customer): &Customer {
        customer
    }

    // Functions to update entities

    public fun update_package_price(wedding_package: &mut WeddingPackage, new_price: u64) {
        wedding_package.price = new_price;
    }

    public fun update_booking_status(booking: &mut Booking, new_status: String) {
        booking.status = new_status;
    }

    public fun update_review_rating(review: &mut CustomerReview, new_rating: u8) {
        review.rating = new_rating;
    }

    public fun update_customer_email(customer: &mut Customer, new_email: String) {
        customer.email = new_email;
    }

    public fun update_customer_name(customer: &mut Customer, new_name: String) {
        customer.name = new_name;
    }

    // Functions to delete entities

    public fun delete_vendor(vendor: Booking) {
        let Booking {
            id,
            vendor_id:_,
            customer_id: _,
            wedding_date: _,
            status: _
        } = vendor;

        object::delete(id);
    }

    // =================== Helper Functions ===================

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx);
    }
}
