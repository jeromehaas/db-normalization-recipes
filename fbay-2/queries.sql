------------------------------------
-- GENERAL QUERIES
------------------------------------

-- GET ALL AUCTIONS
SELECT products.product_id, initial_data.num_bet, initial_data.high_bet, initial_data.auction_end::date, bidders.bidder_id
    FROM initial_data
    JOIN products ON initial_data.product = products.product_name
    JOIN bidders ON initial_data.highest_bidder = bidders.firstname || ' ' || bidders.lastname;

-- GET ALL BIDS FROM SPECIFIC USERS
SELECT auction_id, bidder_id
    FROM auctions
    JOIN bidders ON auctions.fk_highest_bidder_id = bidders.bidder_id;

SELECT auctions.highest_bet, auctions.auction_id, bidders.bidder_id
    FROM auctions
    JOIN bidders ON auctions.fk_highest_bidder_id = bidders.bidder_id;
