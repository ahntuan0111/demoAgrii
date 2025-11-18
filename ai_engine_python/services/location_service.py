import logging
from typing import List, Dict, Any, Tuple, Optional
from services.mongodb_service import (
    get_collection,
    STORES_COLLECTION,
    LOCATIONS_COLLECTION,
)
import math

logger = logging.getLogger(__name__)


def get_province_coordinates(province: str) -> Optional[Tuple[float, float]]:
    """
    Get coordinates for a province from MongoDB
    """
    try:
        locations_collection = get_collection(LOCATIONS_COLLECTION)
        if locations_collection is None:
            return None

        location = locations_collection.find_one({"province": province})
        if location:
            return (location["latitude"], location["longitude"])
        return None
    except Exception as e:
        logger.error(f"Error getting coordinates for {province}: {e}")
        return None


def get_all_province_coordinates() -> Dict[str, Tuple[float, float]]:
    """
    Get all province coordinates from MongoDB
    """
    try:
        locations_collection = get_collection(LOCATIONS_COLLECTION)
        if locations_collection is None:
            return {}

        locations = list(locations_collection.find())
        return {
            loc["province"]: (loc["latitude"], loc["longitude"]) for loc in locations
        }
    except Exception as e:
        logger.error(f"Error getting all province coordinates: {e}")
        return {}


def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calculate the great circle distance between two points on the earth (specified in decimal degrees)
    Returns distance in kilometers
    """
    # Convert decimal degrees to radians
    lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])

    # Haversine formula
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2) ** 2
    )
    c = 2 * math.asin(math.sqrt(a))

    # Radius of earth in kilometers
    r = 6371

    return c * r


def find_nearest_stores(user_location: str, limit: int = 5) -> List[Dict[str, Any]]:
    """
    Find the nearest stores based on user location
    """
    try:
        stores_collection = get_collection(STORES_COLLECTION)
        if stores_collection is None:
            return []

        # Get user coordinates from MongoDB
        user_coords = get_province_coordinates(user_location)
        if not user_coords:
            logger.warning(f"Coordinates not found for location: {user_location}")
            # If we can't find coordinates, search by exact location match
            query = {"location": {"$regex": user_location, "$options": "i"}}
            stores = list(stores_collection.find(query, {"_id": 0}).limit(limit))
            return stores

        user_lat, user_lon = user_coords

        # Get all stores
        all_stores = list(stores_collection.find({}, {"_id": 0}))

        # Calculate distances and add to stores
        stores_with_distance = []
        for store in all_stores:
            store_location = store.get("location", "")
            store_coords = get_province_coordinates(store_location)

            if store_coords:
                store_lat, store_lon = store_coords
                distance = calculate_distance(user_lat, user_lon, store_lat, store_lon)
                store["distance_km"] = round(distance, 2)
                stores_with_distance.append(store)
            else:
                # If we can't find coordinates for the store, add it with a high distance
                store["distance_km"] = 9999
                stores_with_distance.append(store)

        # Sort by distance
        stores_with_distance.sort(key=lambda x: x["distance_km"])

        # Return top stores
        return stores_with_distance[:limit]

    except Exception as e:
        logger.error(f"Error finding nearest stores: {e}")
        return []


def search_stores_by_product_and_location(
    product_name: str, user_location: str, limit: int = 5
) -> List[Dict[str, Any]]:
    """
    Find stores that have a specific product and are near the user location
    """
    try:
        stores_collection = get_collection(STORES_COLLECTION)
        if stores_collection is None:
            return []

        # Get user coordinates from MongoDB
        user_coords = get_province_coordinates(user_location)
        if not user_coords:
            logger.warning(f"Coordinates not found for location: {user_location}")
            # If we can't find coordinates, search by exact location match
            query = {
                "location": {"$regex": user_location, "$options": "i"},
                "san_pham": {"$regex": product_name, "$options": "i"},
            }
            stores = list(stores_collection.find(query, {"_id": 0}).limit(limit))
            return stores

        user_lat, user_lon = user_coords

        # Search for stores with the product (exact match or partial match)
        query = {"san_pham": {"$regex": product_name, "$options": "i"}}
        matching_stores = list(stores_collection.find(query, {"_id": 0}))

        # Calculate distances and add to stores
        stores_with_distance = []
        for store in matching_stores:
            store_location = store.get("location", "")
            store_coords = get_province_coordinates(store_location)

            if store_coords:
                store_lat, store_lon = store_coords
                distance = calculate_distance(user_lat, user_lon, store_lat, store_lon)
                store["distance_km"] = round(distance, 2)
                stores_with_distance.append(store)
            else:
                # If we can't find coordinates for the store, add it with a high distance
                store["distance_km"] = 9999
                stores_with_distance.append(store)

        # Sort by distance
        stores_with_distance.sort(key=lambda x: x["distance_km"])

        # Return top stores
        return stores_with_distance[:limit]

    except Exception as e:
        logger.error(f"Error searching stores by product and location: {e}")
        return []
