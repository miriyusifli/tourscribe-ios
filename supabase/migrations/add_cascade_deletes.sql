-- Add cascading deletes for trip-related tables
-- When a trip is deleted, its trip_items are deleted
-- When a trip_item is deleted, its trip_item_locations are deleted

-- trip_items -> trips
ALTER TABLE trip_items
ADD CONSTRAINT trip_items_trip_id_fkey
    FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE;

-- trip_item_locations -> trip_items
ALTER TABLE trip_item_locations
ADD CONSTRAINT trip_item_locations_trip_item_id_fkey
    FOREIGN KEY (trip_item_id) REFERENCES trip_items(id) ON DELETE CASCADE;
