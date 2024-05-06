#[test_only]
module wedding_marketplace::test_marketplace {
    use sui::test_scenario::{Self as ts, next_tx, Scenario};
    use sui::transfer;
    use sui::test_utils::{assert_eq};
    use sui::coin::{mint_for_testing};
    use sui::object::{Self, UID};
    use sui::sui::SUI;
    use sui::vector::{Self};
    use std::string::{Self};
    use std::option::{Self, Option};

    use wedding_marketplace::marketplace::{Self, Vendor, WeddingPackage, Booking, CustomerReview, Customer, AdminCap};

    const TEST_ADDRESS1: address = @0xB;
    const TEST_ADDRESS2: address = @0xC;

    /// Test the initialization of the marketplace and creation of admin capability
    #[test]
    public fun test_init_and_create_admin() {
        let scenario = ts::new();
        next_tx(scenario, TEST_ADDRESS1);

        // Initialize the marketplace
        wedding_marketplace::marketplace::init(ts::ctx(scenario));

        // Check if AdminCap is created and transferred to TEST_ADDRESS1
        let admin_cap = ts::take_from_sender<AdminCap>(scenario);
        assert_eq(admin_cap.id != object::UID_NULL, true);

        ts::return_to_sender(scenario, admin_cap);
        ts::end(scenario);
    }

    /// Test the creation and retrieval of a customer
    #[test]
    public fun test_create_customer() {
        let scenario = ts::new();
        next_tx(scenario, TEST_ADDRESS1);

        // Create a new customer
        let customer = wedding_marketplace::marketplace::create_customer(
            string::utf8(b"John Doe"),
            string::utf8(b"john@example.com"),
            string::utf8(b"123-456-7890"),
            ts::ctx(scenario),
        );

        // Verify customer details
        assert_eq(customer.name, string::utf8(b"John Doe"));
        assert_eq(customer.email, string::utf8(b"john@example.com"));
        assert_eq(customer.contact_number, string::utf8(b"123-456-7890"));

        ts::return_to_sender(scenario, customer);
        ts::end(scenario);
    }

    /// Test the creation of a vendor and its retrieval
    #[test]
    public fun test_create_vendor() {
        let scenario = ts::new();
        next_tx(scenario, TEST_ADDRESS1);

        // Create a new vendor
        let vendor = wedding_marketplace::marketplace::create_vendor(
            string::utf8(b"Florist"),
            string::utf8(b"Beautiful flower arrangements"),
            string::utf8(b"987-654-3210"),
            string::utf8(b"Florist"),
            ts::ctx(scenario),
        );

        // Verify vendor details
        assert_eq(vendor.name, string::utf8(b"Florist"));
        assert_eq(vendor.description, string::utf8(b"Beautiful flower arrangements"));
        assert_eq(vendor.contact, string::utf8(b"987-654-3210"));
        assert_eq(vendor.service_type, string::utf8(b"Florist"));

        ts::return_to_sender(scenario, vendor);
        ts::end(scenario);
    }

    /// Test the creation of a wedding package
    #[test]
    public fun test_create_wedding_package() {
        let scenario = ts::new();
        next_tx(scenario, TEST_ADDRESS1);

        // Create a new vendor
        let vendor = wedding_marketplace::marketplace::create_vendor(
            string::utf8(b"Photographer"),
            string::utf8(b"Captures beautiful moments"),
            string::utf8(b"555-555-5555"),
            string::utf8(b"Photographer"),
            ts::ctx(scenario),
        );

        // Create a new wedding package for this vendor
        let package = wedding_marketplace::marketplace::create_package(
            &vendor.id,
            string::utf8(b"Gold Package"),
            5000,
            string::utf8(b"Full-day photography coverage"),
            ts::ctx(scenario),
        );

        // Verify package details
        assert_eq(package.name, string::utf8(b"Gold Package"));
        assert_eq(package.price, 5000);
        assert_eq(package.details, string::utf8(b"Full-day photography coverage"));
        assert_eq(package.vendor_id, vendor.id);

        ts::return_to_sender(scenario, package);
        ts::end(scenario);
    }

    /// Test creating a booking and updating its status
    #[test]
    public fun test_create_and_update_booking() {
        let scenario = ts::new();
        next_tx(scenario, TEST_ADDRESS1);

        // Create a new customer
        let customer = wedding_marketplace::marketplace::create_customer(
            string::utf8(b"Jane Doe"),
            string::utf8(b"jane@example.com"),
            string::utf8(b"456-123-7890"),
            ts::ctx(scenario),
        );

        // Create a new vendor
        let vendor = wedding_marketplace::marketplace::create_vendor(
            string::utf8(b"Florist"),
            string::utf8(b"Beautiful flower arrangements"),
            string::utf8(b"987-654-3210"),
            string::utf8(b"Florist"),
            ts::ctx(scenario),
        );

        // Create a new booking
        let booking = wedding_marketplace::marketplace::create_booking(
            &vendor.id,
            &customer.id,
            1672531200, // Arbitrary Unix timestamp for a wedding date
            string::utf8(b"Booked"),
            ts::ctx(scenario),
        );

        // Verify booking details
        assert_eq(booking.vendor_id, vendor.id);
        assert_eq(booking.customer_id, customer.id);
        assert_eq(booking.status, string::utf8(b"Booked"));

        // Update booking status to "Confirmed"
        wedding_marketplace::marketplace::update_booking_status(
            &mut booking,
            string::utf8(b"Confirmed"),
        );

        assert_eq(booking.status, string::utf8(b"Confirmed"));

        ts::return_to_sender(scenario, booking);
        ts::end(scenario);
    }

    /// Test creating and updating customer reviews
    #[test]
    public fun test_create_and_update_customer_review() {
        let scenario = ts::new();
        next_tx(scenario, TEST_ADDRESS1);

        // Create a new customer
        let customer = wedding_marketplace::marketplace::create_customer(
            string::utf8(b"Mark"),
            string::utf8(b"mark@example.com"),
            string::utf8(b"789-123-4560"),
            ts::ctx(scenario),
        );

        // Create a new vendor
        let vendor = wedding_marketplace::marketplace::create_vendor(
            string::utf8(b"DJ"),
            string::utf8(b"Great music for weddings"),
            string::utf8(b"123-456-7890"),
            string::utf8(b"DJ"),
            ts::ctx(scenario),
        );

        // Create a new customer review for the vendor
        let review = wedding_marketplace::marketplace::create_review(
            &vendor.id,
            &customer.id,
            8,  // Out of 10
            string::utf8(b"Great service and music!"),
            ts::ctx(scenario),
        );

        // Verify review details
        assert_eq(review.vendor_id, vendor.id);
        assert_eq(review.customer_id, customer.id);
        assert_eq(review.rating, 8);
        assert_eq(review.comments, string::utf8(b"Great service and music!"));

        // Update the review rating
        wedding_marketplace::marketplace::update_review_rating(
            &mut review,
            9,  // Out of 10
        );

        assert_eq(review.rating, 9);

        ts::return_to_sender(scenario, review);
        ts::end(scenario);
    }
}
