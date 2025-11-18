import pandas as pd  # pyright: ignore[reportMissingImports]
import os
from typing import Dict, List, Any
import logging
import datetime

# Load environment variables first
try:
    from dotenv import load_dotenv  # pyright: ignore[reportMissingImports]

    load_dotenv()
except ImportError:
    pass  # dotenv not available, continue with default environment variables

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Try to import pymongo, but handle if it's not available
try:
    from pymongo import MongoClient  # pyright: ignore[reportMissingImports]

    MONGO_AVAILABLE_FLAG = True
except ImportError:
    logging.warning("pymongo not installed. MongoDB features will be disabled.")
    MONGO_AVAILABLE_FLAG = False
    MongoClient = None

# MongoDB connection
MONGO_AVAILABLE = False  # Default to False
if MONGO_AVAILABLE_FLAG:  # Check if pymongo was successfully imported
    MONGO_URI = os.getenv("MONGO_URI", "mongodb://admin:password@localhost:27017/")
    DB_NAME = os.getenv("MONGO_DB_NAME", "ai_nha_nong")
    try:
        # Handle both local MongoDB and MongoDB Atlas connections
        if "mongodb+srv://" in MONGO_URI:
            # For MongoDB Atlas, use different connection parameters
            client = (
                MongoClient(
                    MONGO_URI, serverSelectionTimeoutMS=10000, connectTimeoutMS=20000
                )
                if MongoClient
                else None
            )
        else:
            # For local MongoDB
            client = (
                MongoClient(MONGO_URI, serverSelectionTimeoutMS=5000)
                if MongoClient
                else None
            )
        # Test the connection
        if client:
            client.server_info()  # Will raise an exception if cannot connect
            db = client[DB_NAME]
            MONGO_AVAILABLE = True
            logger.info(f"Successfully connected to MongoDB at {MONGO_URI}")
    except Exception as e:
        logger.error(f"Failed to connect to MongoDB at {MONGO_URI}: {e}")
        logger.info("Falling back to JSON file data")
else:
    logger.info("MongoDB support disabled due to missing pymongo package")

# Collection names
PRODUCTS_COLLECTION = "products"
STORES_COLLECTION = "stores"
FARMERS_COLLECTION = "farmers"
TREATMENTS_COLLECTION = "treatments"
KEYWORDS_COLLECTION = "keywords"
DISEASES_COLLECTION = "diseases"
CROPS_COLLECTION = "crops"
SUGGESTIONS_COLLECTION = "suggestions"

# Add new collection for storing user locations
LOCATIONS_COLLECTION = "locations"

# Add new collection for storing prompts
PROMPTS_COLLECTION = "prompts"

# Add new collection for storing user locations
LOCATIONS_COLLECTION = "locations"


def get_collection(collection_name: str):
    """Get a MongoDB collection"""
    if not MONGO_AVAILABLE:
        logger.warning(
            f"MongoDB not available, cannot get collection {collection_name}"
        )
        return None
    return db[collection_name]


def load_mock_data():
    """Load mock data from MongoDB and convert to DataFrame"""
    if not MONGO_AVAILABLE:
        # Fallback to JSON service if MongoDB is not available
        from services.json_service import (  # pyright: ignore[reportMissingImports]
            load_mock_data as json_load_mock_data,
        )  # pyright: ignore[reportMissingImports]

        return json_load_mock_data()

    try:
        # Get collections
        products_collection = get_collection(PRODUCTS_COLLECTION)
        stores_collection = get_collection(STORES_COLLECTION)
        farmers_collection = get_collection(FARMERS_COLLECTION)

        # Check if collections are available
        if (
            products_collection is None
            or stores_collection is None
            or farmers_collection is None
        ):
            # Fallback to JSON service if MongoDB collections are not available
            from services.json_service import (  # pyright: ignore[reportMissingImports]
                load_mock_data as json_load_mock_data,
            )  # pyright: ignore[reportMissingImports]

            return json_load_mock_data()

        # Load data from collections
        products = (
            list(products_collection.find({}, {"_id": 0}))
            if products_collection is not None
            else []
        )
        stores = (
            list(stores_collection.find({}, {"_id": 0}))
            if stores_collection is not None
            else []
        )
        farmers = (
            list(farmers_collection.find({}, {"_id": 0}))
            if farmers_collection is not None
            else []
        )

        # Flatten products data: each row = 1 product with its details
        records = []
        for product in products:
            records.append(
                {
                    "ten_sp": product["ten_sp"],
                    "cay_trong": product["cay_trong"],
                    "benh_lien_quan": product["benh_lien_quan"],
                    "action": product["action"],
                    "usage_count": product.get("usage_count", 0),
                    "location": "",  # Will be filled from stores
                    "farmer_role": "",  # Will be filled from farmers
                }
            )

        # Add store information to products
        for store in stores:
            for product_name in store["san_pham"]:
                # Find matching product and add location
                for record in records:
                    if record["ten_sp"] == product_name:
                        record["location"] = store["location"]
                        break

        # Add farmer information (simplified)
        for farmer in farmers:
            location = farmer["dia_diem"]
            for crop_info in farmer["cay_trong_vung"]:
                # Add farmer role for matching products
                for record in records:
                    if record["cay_trong"] == crop_info["cay_trong"]:
                        record["farmer_role"] = farmer["ten"]
                        if not record["location"]:
                            record["location"] = location
                        break

        df = pd.DataFrame(records)
        return df
    except Exception as e:
        logger.error(f"Error loading data from MongoDB: {e}")
        # Fallback to JSON service if there's an error
        from services.json_service import (  # pyright: ignore[reportMissingImports]
            load_mock_data as json_load_mock_data,
        )  # pyright: ignore[reportMissingImports]

        return json_load_mock_data()


def load_treatments_data():
    """Load treatment comparison data from MongoDB"""
    if not MONGO_AVAILABLE:
        # Fallback to JSON service if MongoDB is not available
        from services.json_service import (  # pyright: ignore[reportMissingImports]
            load_treatments_data as json_load_treatments_data,
        )

        return json_load_treatments_data()

    try:
        treatments_collection = get_collection(TREATMENTS_COLLECTION)

        # Check if collection is available
        if treatments_collection is None:
            # Fallback to JSON service if MongoDB collection is not available
            from services.json_service import (  # pyright: ignore[reportMissingImports]
                load_treatments_data as json_load_treatments_data,
            )

            return json_load_treatments_data()

        # Return treatments data
        return (
            list(treatments_collection.find({}, {"_id": 0}))
            if treatments_collection
            else []
        )
    except Exception as e:
        logger.error(f"Error loading treatments from MongoDB: {e}")
        # Fallback to JSON service if there's an error
        from services.json_service import (  # pyright: ignore[reportMissingImports]
            load_treatments_data as json_load_treatments_data,
        )

        return json_load_treatments_data()


def search_data(keywords: dict):
    """
    Search DataFrame based on extracted keywords
    Keep same logic as JSON version: AND first, fallback OR
    """
    df = load_mock_data()
    if df.empty:
        return []

    # Check if we have any meaningful keywords
    # If all keywords are empty or whitespace, return empty results
    meaningful_keywords = {
        k: v for k, v in keywords.items() if k != "model_used" and v and str(v).strip()
    }

    if not meaningful_keywords:
        return []

    filtered_df = df.copy()

    # Define column mapping
    column_mapping = {
        "crop": "cay_trong",
        "disease": "benh_lien_quan",
        "product": "ten_sp",
        "location": "location",
        "action": "action",
    }

    # AND match - only search in relevant columns
    search_columns = ["cay_trong", "benh_lien_quan", "ten_sp", "location", "action"]
    for key, value in keywords.items():
        if value and str(value).strip():  # Only search for non-empty values
            column_key = column_mapping.get(key, key)
            if column_key in search_columns and column_key in df.columns:
                filtered_df = filtered_df[
                    filtered_df[column_key].str.contains(
                        str(value), case=False, na=False, regex=False
                    )
                ]

    # fallback OR if too few results
    if len(filtered_df) < 3:
        filtered_df = df.copy()
        mask = pd.Series([False] * len(df))
        for key, value in keywords.items():
            if value and str(value).strip():  # Only search for non-empty values
                column_key = column_mapping.get(key, key)
                if column_key in search_columns and column_key in df.columns:
                    # For disease matching, be more flexible to handle variations
                    if key == "disease":
                        # Split the disease term and match any part
                        disease_terms = str(value).lower().split()
                        disease_mask = pd.Series([False] * len(df))
                        for term in disease_terms:
                            if (
                                len(term) > 1
                            ):  # Only match terms with more than 1 character
                                disease_mask |= df[column_key].str.contains(
                                    term, case=False, na=False, regex=False
                                )
                        mask |= disease_mask
                    else:
                        mask |= df[column_key].str.contains(
                            str(value), case=False, na=False, regex=False
                        )
        filtered_df = df[mask]

    # Sort by usage count if available
    if "usage_count" in filtered_df.columns:
        filtered_df = filtered_df.sort_values("usage_count", ascending=False)

    # Limit results top 10
    return filtered_df.head(10).to_dict("records")


def search_data_by_keywords(keywords: dict):
    """
    Search for data in all collections based on keywords
    Returns combined results from products, stores, and farmers
    Each category is limited to 3-4 results for better UI display
    """
    if not MONGO_AVAILABLE:
        return []

    try:
        # Get collections
        products_collection = get_collection(PRODUCTS_COLLECTION)
        stores_collection = get_collection(STORES_COLLECTION)
        farmers_collection = get_collection(FARMERS_COLLECTION)

        # Check if collections are available
        if (
            products_collection is None
            or stores_collection is None
            or farmers_collection is None
        ):
            return []

        results = []

        # Search in products - limit to 5 results
        product_query = {}
        if keywords.get("crop"):
            product_query["cay_trong"] = {"$regex": keywords["crop"], "$options": "i"}
        if keywords.get("disease"):
            product_query["benh_lien_quan"] = {
                "$regex": keywords["disease"],
                "$options": "i",
            }
        if keywords.get("product"):
            product_query["ten_sp"] = {"$regex": keywords["product"], "$options": "i"}

        if product_query:
            product_results = list(
                products_collection.find(product_query, {"_id": 0}).limit(5)
            )
            for product in product_results:
                results.append(
                    {
                        "type": "product",
                        "crop": product.get("cay_trong", ""),
                        "disease": product.get("benh_lien_quan", ""),
                        "product": product.get("ten_sp", ""),
                        "location": "",
                        "farmer_role": "",
                        "action": product.get("action", ""),
                    }
                )

        # If we have disease or product keywords, also search by keywords
        if keywords.get("disease") or keywords.get("product"):
            # Extract keywords for matching
            search_keywords = []
            if keywords.get("disease"):
                search_keywords.extend(keywords["disease"].lower().split())
            if keywords.get("product"):
                search_keywords.extend(keywords["product"].lower().split())

            # Search for products with matching keywords
            keyword_products = search_products_by_keywords_extended(
                search_keywords, products_collection
            )
            for product in keyword_products:
                # Avoid duplicates
                if not any(r.get("product") == product.get("ten_sp") for r in results):
                    results.append(
                        {
                            "type": "product",
                            "crop": product.get("cay_trong", ""),
                            "disease": product.get("benh_lien_quan", ""),
                            "product": product.get("ten_sp", ""),
                            "location": "",
                            "farmer_role": "",
                            "action": product.get("action", ""),
                        }
                    )

        # Search in stores - limit to 5 results
        store_query = {}
        if keywords.get("location"):
            store_query["location"] = {"$regex": keywords["location"], "$options": "i"}

        # If we have a disease, try to find stores that might carry relevant products
        # Even if we can't find exact matches, we'll return some stores in the area
        if keywords.get("disease") or keywords.get("product"):
            # Get all stores if we have location, otherwise get some stores
            if store_query:
                store_results = list(
                    stores_collection.find(store_query, {"_id": 0}).limit(5)
                )
            else:
                # If no specific location, get stores from different provinces
                store_results = list(stores_collection.find({}, {"_id": 0}).limit(5))
        else:
            # If no disease or product specified, use location or get some stores
            if store_query:
                store_results = list(
                    stores_collection.find(store_query, {"_id": 0}).limit(5)
                )
            else:
                # Get a few stores as examples
                store_results = list(stores_collection.find({}, {"_id": 0}).limit(5))

        store_count = 0
        for store in store_results:
            if store_count >= 5:  # Ensure we don't exceed the limit
                break
            # Add store result
            results.append(
                {
                    "type": "store",
                    "crop": keywords.get("crop", ""),
                    "disease": keywords.get("disease", ""),
                    "product": store.get("ten_cua_hang", ""),
                    "location": store.get("location", ""),
                    "farmer_role": "Cửa hàng VTNN",
                    "action": "Mua hàng",
                }
            )
            store_count += 1

        # Search in farmers - limit to 5 results
        farmer_query = {}
        if keywords.get("crop"):
            farmer_query["cay_trong_vung.cay_trong"] = {
                "$regex": keywords["crop"],
                "$options": "i",
            }
        if keywords.get("location"):
            farmer_query["dia_diem"] = {"$regex": keywords["location"], "$options": "i"}

        if farmer_query:
            farmer_results = list(
                farmers_collection.find(farmer_query, {"_id": 0}).limit(5)
            )
            farmer_count = 0
            for farmer in farmer_results:
                if farmer_count >= 5:  # Ensure we don't exceed the limit
                    break
                # Add each crop specialty as a separate result
                for crop_info in farmer.get("cay_trong_vung", [])[
                    :1
                ]:  # Limit to 1 crop per farmer
                    if farmer_count >= 5:  # Check again inside the loop
                        break
                    results.append(
                        {
                            "type": "farmer",
                            "crop": crop_info.get("cay_trong", ""),
                            "disease": "",
                            "product": farmer.get("ten", ""),
                            "location": farmer.get("dia_diem", ""),
                            "farmer_role": "Lão nông",
                            "action": "Tư vấn",
                        }
                    )
                    farmer_count += 1

        # Ensure we have at least some results
        if not results and (
            keywords.get("crop") or keywords.get("disease") or keywords.get("product")
        ):
            # If no specific matches found, get some general results
            general_products = list(products_collection.find({}, {"_id": 0}).limit(3))
            for product in general_products:
                results.append(
                    {
                        "type": "product",
                        "crop": product.get("cay_trong", ""),
                        "disease": product.get("benh_lien_quan", ""),
                        "product": product.get("ten_sp", ""),
                        "location": "",
                        "farmer_role": "",
                        "action": product.get("action", ""),
                    }
                )

        return results
    except Exception as e:
        logger.error(f"Error searching data by keywords: {e}")
        return []


def search_treatments(crop: str, disease: str, location: str = ""):
    """
    Search for treatment comparisons for a specific crop and disease
    Optionally filter by location
    """
    # Ensure crop and disease are strings
    if not isinstance(crop, str):
        crop = str(crop) if crop else ""
    if not isinstance(disease, str):
        disease = str(disease) if disease else ""
    if not isinstance(location, str):
        location = str(location) if location else ""

    treatments_data = load_treatments_data()

    # Find matching treatment
    for treatment in treatments_data:
        crop_match = treatment["cay_trong"].lower() == crop.lower()
        disease_match = treatment["benh"].lower() == disease.lower()
        location_match = (
            True if not location else treatment["vung_mien"].lower() == location.lower()
        )

        if crop_match and disease_match and location_match:
            # Sort farmer treatments by usage count (so nguoi dung)
            if "farmer_treatments" in treatment:
                treatment["farmer_treatments"].sort(
                    key=lambda x: x.get("so_nguoi_dung", 0), reverse=True
                )
            return treatment

    return None


def get_all_unique_values():
    """Return unique values for each column"""
    df = load_mock_data()
    if df.empty:
        return {}

    unique_values = {col: df[col].unique().tolist() for col in df.columns}
    return unique_values


def import_data_from_json(json_data: Dict[str, Any]):
    """Import data from JSON format to MongoDB collections"""
    if not MONGO_AVAILABLE:
        logger.warning("MongoDB not available, cannot import data")
        return False

    try:
        # Import crops
        if "crops" in json_data:
            crops_collection = get_collection(CROPS_COLLECTION)
            if crops_collection is not None:
                crops_collection.delete_many({})  # Clear existing data
                # Convert crop data to the correct format
                crop_docs = [{"name": crop["name"]} for crop in json_data["crops"]]
                if crop_docs:
                    crops_collection.insert_many(crop_docs)
                logger.info(f"Imported {len(crop_docs)} crops")

        # Import diseases
        if "diseases" in json_data:
            diseases_collection = get_collection(DISEASES_COLLECTION)
            if diseases_collection is not None:
                diseases_collection.delete_many({})  # Clear existing data
                if json_data["diseases"]:
                    diseases_collection.insert_many(json_data["diseases"])
                logger.info(f"Imported {len(json_data['diseases'])} diseases")

        # Import products
        if "products" in json_data:
            products_collection = get_collection(PRODUCTS_COLLECTION)
            if products_collection is not None:
                products_collection.delete_many({})  # Clear existing data
                if json_data["products"]:
                    products_collection.insert_many(json_data["products"])
                logger.info(f"Imported {len(json_data['products'])} products")

        # Import stores
        if "stores" in json_data:
            stores_collection = get_collection(STORES_COLLECTION)
            if stores_collection is not None:
                stores_collection.delete_many({})  # Clear existing data
                if json_data["stores"]:
                    stores_collection.insert_many(json_data["stores"])
                logger.info(f"Imported {len(json_data['stores'])} stores")

        # Import farmers
        if "farmers" in json_data:
            farmers_collection = get_collection(FARMERS_COLLECTION)
            if farmers_collection is not None:
                farmers_collection.delete_many({})  # Clear existing data
                if json_data["farmers"]:
                    farmers_collection.insert_many(json_data["farmers"])
                logger.info(f"Imported {len(json_data['farmers'])} farmers")

        # Import treatments
        if "treatments" in json_data:
            treatments_collection = get_collection(TREATMENTS_COLLECTION)
            if treatments_collection is not None:
                treatments_collection.delete_many({})  # Clear existing data
                if json_data["treatments"]:
                    treatments_collection.insert_many(json_data["treatments"])
                logger.info(f"Imported {len(json_data['treatments'])} treatments")

        logger.info("Data import completed successfully")
        return True
    except Exception as e:
        logger.error(f"Error importing data to MongoDB: {e}")
        return False


def get_all_keywords():
    """Get all keywords from MongoDB"""
    if not MONGO_AVAILABLE:
        return []

    try:
        keywords_collection = get_collection(KEYWORDS_COLLECTION)
        if keywords_collection is None:
            return []

        return list(keywords_collection.find({}, {"_id": 0, "keyword": 1, "type": 1}))
    except Exception as e:
        logger.error(f"Error loading keywords from MongoDB: {e}")
        return []


def get_all_diseases():
    """Get all diseases from MongoDB"""
    if not MONGO_AVAILABLE:
        return []

    try:
        diseases_collection = get_collection(DISEASES_COLLECTION)
        if diseases_collection is None:
            return []

        return list(diseases_collection.find({}, {"_id": 0, "name": 1, "crop": 1}))
    except Exception as e:
        logger.error(f"Error loading diseases from MongoDB: {e}")
        return []


def get_all_crops():
    """Get all crops from MongoDB"""
    if not MONGO_AVAILABLE:
        return []

    try:
        crops_collection = get_collection(CROPS_COLLECTION)
        if crops_collection is None:
            return []

        return list(crops_collection.find({}, {"_id": 0, "name": 1}))
    except Exception as e:
        logger.error(f"Error loading crops from MongoDB: {e}")
        return []


def add_keyword(keyword: str, type: str):
    """Add a new keyword to MongoDB"""
    if not MONGO_AVAILABLE:
        return False

    try:
        keywords_collection = get_collection(KEYWORDS_COLLECTION)
        if keywords_collection is None:
            return False

        # Check if keyword already exists
        existing = keywords_collection.find_one({"keyword": keyword, "type": type})
        if existing:
            return True  # Already exists

        # Add new keyword
        keywords_collection.insert_one({"keyword": keyword, "type": type})
        logger.info(f"Added keyword: {keyword} ({type})")
        return True
    except Exception as e:
        logger.error(f"Error adding keyword to MongoDB: {e}")
        return False


def add_disease(name: str, crop: str):
    """Add a new disease to MongoDB"""
    if not MONGO_AVAILABLE:
        return False

    try:
        diseases_collection = get_collection(DISEASES_COLLECTION)
        if diseases_collection is None:
            return False

        # Check if disease already exists
        existing = diseases_collection.find_one({"name": name, "crop": crop})
        if existing:
            return True  # Already exists

        # Add new disease
        diseases_collection.insert_one({"name": name, "crop": crop})
        logger.info(f"Added disease: {name} for crop {crop}")
        return True
    except Exception as e:
        logger.error(f"Error adding disease to MongoDB: {e}")
        return False


def add_crop(name: str):
    """Add a new crop to MongoDB"""
    if not MONGO_AVAILABLE:
        return False

    try:
        crops_collection = get_collection(CROPS_COLLECTION)
        if crops_collection is None:
            return False

        # Check if crop already exists
        existing = crops_collection.find_one({"name": name})
        if existing:
            return True  # Already exists

        # Add new crop
        crops_collection.insert_one({"name": name})
        logger.info(f"Added crop: {name}")
        return True
    except Exception as e:
        logger.error(f"Error adding crop to MongoDB: {e}")
        return False


def save_prompt(prompt: str, keywords=None):
    """Save user prompt to MongoDB"""
    if not MONGO_AVAILABLE:
        return False

    try:
        prompts_collection = get_collection(PROMPTS_COLLECTION)
        if prompts_collection is None:
            return False

        # Add timestamp and keywords
        data = {
            "prompt": prompt,
            "keywords": keywords or {},
            "saved_at": datetime.datetime.now(),
        }

        # Add new prompt data
        prompts_collection.insert_one(data)
        logger.info(f"Added prompt: {prompt}")
        return True
    except Exception as e:
        logger.error(f"Error adding prompt to MongoDB: {e}")
        return False


def save_suggestion_data(data: dict):
    """Save suggestion data to MongoDB"""
    if not MONGO_AVAILABLE:
        return False

    try:
        suggestions_collection = get_collection(SUGGESTIONS_COLLECTION)
        if suggestions_collection is None:
            return False

        # Add timestamp
        data["saved_at"] = datetime.datetime.now()

        # Add new suggestion data
        suggestions_collection.insert_one(data)
        logger.info("Added suggestion data")
        return True
    except Exception as e:
        logger.error(f"Error adding suggestion data to MongoDB: {e}")
        return False


def get_all_suggestions():
    """Get all suggestions from MongoDB"""
    if not MONGO_AVAILABLE:
        return []

    try:
        suggestions_collection = get_collection(SUGGESTIONS_COLLECTION)
        if suggestions_collection is None:
            return []

        return list(suggestions_collection.find({}, {"_id": 0}))
    except Exception as e:
        logger.error(f"Error loading suggestions from MongoDB: {e}")
        return []


def search_products_by_keywords_extended(search_keywords: list, products_collection):
    """
    Search for products that match the given keywords in their keyword fields
    """
    try:
        if not search_keywords:
            return []

        # Search for products with matching keywords in their keywords field
        query = {"keywords": {"$in": search_keywords}}
        products = list(products_collection.find(query, {"_id": 0}).limit(4))

        # If no results found, try partial matching
        if not products:
            # Create regex patterns for partial matching
            regex_patterns = [
                {"keywords": {"$regex": keyword, "$options": "i"}}
                for keyword in search_keywords
            ]
            if regex_patterns:
                # Use $or to match any of the patterns
                query = {"$or": regex_patterns}
                products = list(products_collection.find(query, {"_id": 0}).limit(4))

        return products
    except Exception as e:
        logger.error(f"Error searching products by keywords: {e}")
        return []
