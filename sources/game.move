module wedding_marketplace::wedding_marketplace {
    use std::option::{Option, some, none};
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::string::{Self, String};
    use sui::vector::{Self, vec, push, borrow};

    /// Vendor struct with basic details
    struct Vendor has key, store {
        id: UID,
        name: String,
        description: String,
        contact: String,
        service_type: String, // e.g., "Photographer", "Florist", etc.
    }

    /// Wedding package with price and details
    struct WeddingPackage has key, store {
        id: UID,
        vendor_id: UID,
        name: String,
        price: u64,
        details: String,
    }

    /// Booking struct representing a booking made by a couple
    struct Booking has key, store {
        id: UID,
        vendor_id: UID,
        customer_id: UID,
        wedding_date: u64, // Using u64 for simplicity
        status: String, // e.g., "Booked", "Confirmed", etc.
    }

    /// Customer Review struct
    struct CustomerReview has key, store {
        id: UID,
        vendor_id: UID,
        customer_id: UID,
        rating: u8, // Rating out of 10
        comments: String, // Customer comments
    }

    /// Customer struct representing a customer in the marketplace
    struct Customer has key, store {
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
        let admin_cap = AdminCap { id: object::new(ctx) };
        transfer::transfer(admin_cap, tx_context::sender(ctx));
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

    public fun create_vendor(
        name: String,
        description: String,
        contact: String,
        service_type: String,
        ctx: &mut TxContext,
    ): Vendor {
        Vendor {
            id: object::new(ctx),
            name,
            description,
            contact,
            service_type,
        }
    }

    public fun create_package(
        vendor_id: &UID,
        name: String,
        price: u64,
        details: String,
        ctx: &mut TxContext,
    ): WeddingPackage {
        WeddingPackage {
            id: object::new(ctx),
            vendor_id: *vendor_id,
            name,
            price,
            details,
        }
    }

    public fun create_booking(
        vendor_id: &UID,
        customer_id: &UID,
        wedding_date: u64,
        status: String,
        ctx: &mut TxContext,
    ): Booking {
        Booking {
            id: object::new(ctx),
            vendor_id: *vendor_id,
            customer_id: *customer_id,
            wedding_date,
            status,
        }
    }

    public fun create_review(
        vendor_id: &UID,
        customer_id: &UID,
        rating: u8,
        comments: String,
        ctx: &mut TxContext,
    ): CustomerReview {
        CustomerReview {
            id: object::new(ctx),
            vendor_id: *vendor_id,
            customer_id: *customer_id,
            rating,
            comments,
        }
    }

    // Functions to read data

    public fun get_vendor(vendor: &Vendor): &Vendor {
        vendor
    }

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

    public entry fun update_vendor_name(vendor: &mut Vendor, new_name: String) {
        vendor.name = new_name;
    }

    public entry fun update_package_price(wedding_package: &mut WeddingPackage, new_price: u64) {
        wedding_package.price = new_price;
    }

    public entry fun update_booking_status(booking: &mut Booking, new_status: String) {
        booking.status = new_status;
    }

    public entry fun update_review_rating(review: &mut CustomerReview, new_rating: u8) {
        review.rating = new_rating;
    }

    public entry fun update_customer_email(customer: &mut Customer, new_email: String) {
        customer.email = new_email;
    }

    public entry fun update_customer_name(customer: &mut Customer, new_name: String) {
        customer.name = new_name;
    }

    // Functions to delete entities

    public entry fun delete_vendor(vendor: Vendor) {
        object::delete(vendor.id);
    }

    public entry fun delete_package(package: WeddingPackage) {
        object::delete(package.id);
    }

    public entry fun delete_booking(booking: Booking) {
        object::delete(booking.id);
    }

    public entry fun delete_review(review: CustomerReview) {
        object::delete(review.id);
    }

    public entry fun delete_customer(customer: Customer) {
        object::delete(customer.id);
    }

    // Added Functions

    // Function to get all packages for a vendor
    public fun get_vendor_packages(vendor_id: &UID): vector<&WeddingPackage> {
        let packages = vec::empty<&WeddingPackage>();
        object::batch_for_each_id_owned(
            borrow(vendor_id),
            |package_id: &UID| {
                if (let Some(package) = object::borrow_object<WeddingPackage>(package_id)) {
                    push(&mut packages, package);
                }
            },
        );
        packages
    }

    // Function to get all bookings for a vendor
    public fun get_vendor_bookings(vendor_id: &UID): vector<&Booking> {
        let bookings = vec::empty<&Booking>();
        object::batch_for_each_id_owned(
            borrow(vendor_id),
            |booking_id: &UID| {
                if (let Some(booking) = object::borrow_object<Booking>(booking_id)) {
                    push(&mut bookings, booking);
                }
            },
        );
        bookings
    }
}